From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Mon, 08 Mar 2010 09:35:21 -0800
Message-ID: <m1pr3eu36u.fsf@fess.ebiederm.org>
References: <20100303000743.GA13744@us.ibm.com>
	<m1ocj6qljj.fsf@fess.ebiederm.org> <4B8E9370.3050300@parallels.com>
	<m17hptjh3m.fsf@fess.ebiederm.org> <4B9158F5.5040205@parallels.com>
	<m1vdda1pmx.fsf@fess.ebiederm.org> <4B926B1B.5070207@free.fr>
	<m1aaulyy5c.fsf@fess.ebiederm.org> <4B92C886.9020507@free.fr>
	<m1fx4bxlfy.fsf@fess.ebiederm.org> <20100308170719.GD6399@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	Pavel Emelyanov <xemul@parallels.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100308170719.GD6399@us.ibm.com> (Serge E. Hallyn's message of "Mon\, 8 Mar 2010 11\:07\:19 -0600")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Quoting Eric W. Biederman (ebiederm@xmission.com):
>> 
>> I have take an snapshot of my development tree and placed it at.
>> 
>> 
>> git://git.kernel.org/pub/scm/linux/people/ebiederm/linux-2.6.33-nsfd-v5.git
>> 
>> 
>> >> I am going to explore a bit more.  Given that nsfd is using the same
>> >> permission checks as a proc file, I think I can just make it a proc
>> >> file.  Something like "/proc/<pid>/ns/net".  With a little luck that
>> >> won't suck too badly.
>> >>   
>> > Ah ! yes. Good idea.
>> 
>> It is a hair more code to use proc files but nothing worth counting.
>> 
>> Probably the biggest thing I am aware of right now in my development
>> tree is in getting uids to pass properly between unix domain sockets
>> I would up writing this cred_to_ucred function.
>> 
>> Serge can you take a look and check my logic, and do you have
>> any idea of where we should place something like pid_vnr but
>> for the uid namespace?
>
> Well my first thought was user_namespace, but I'm thinking kernel/cred.c is
> the best place for it.

Thanks.

>> void cred_to_ucred(struct pid *pid, const struct cred *cred,
>> 		   struct ucred *ucred)
>> {
>> 	ucred->pid = pid_vnr(pid);
>> 	ucred->uid = ucred->gid = -1;
>> 	if (cred) {
>> 		struct user_namespace *cred_ns = cred->user->user_ns;
>> 		struct user_namespace *current_ns = current_user_ns();
>> 		struct user_namespace *tmp;
>> 
>> 		if (likely(cred_ns == current_ns)) {
>> 			ucred->uid = cred->euid;
>> 			ucred->gid = cred->egid;
>> 		} else {
>> 			/* Is cred in a child user namespace */
>> 			tmp = cred_ns;
>> 			do {
>> 				tmp = tmp->creator->user_ns;
>> 				if (tmp == current_ns) {
>
> 	Hmm, I think you want to catch one level up - so the creator itself
> 	is in current_user_ns, so

>
> 	do {
> 		if (tmp->creator->user_ns == current_ns) {
> 			ucred->uid = tmp->creator->uid;
> 			ucred->gid = tmp->creator_gid;
> 			return;
> 		}
> 		tmp = tmp->creator->user_ns;
> 	} while (tmp != &init_user_ns);

Good catch.  

>> 					ucred->uid = tmp->creator->uid;
>> 					ucred->gid = overflowgid;
>
> 			should we start recording a user_ns->creator_gid
> 			instead?

I had a similar question.  Possibly we can just grab the creators cred.


>> 					return;
>> 				}
>> 			} while (tmp != &init_user_ns);
>> 
>> 			/* Is cred the creator of my user namespace,
>> 			 * or the creator of one of it's parents?
>> 			 */
>> 			for( tmp = current_ns; tmp != &init_user_ns;
>> 			     tmp = tmp->creator->user_ns) {
>> 				if (cred->user == tmp->creator) {
>> 					ucred->uid = 0;
>> 					ucred->gid = 0;
>> 					return;
>> 				}
>> 			}
>
> That looks right.
>
>> 			/* No user namespace relationship so no mapping */
>> 			ucred->uid = overflowuid;
>> 			ucred->gid = overflowgid;
>> 		}
>> 	}
>> }

Eric

