From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH nf-next] netns: add and use net_ns_barrier
Date: Wed, 31 May 2017 13:21:00 -0700
Message-ID: <CAPWQB7F6cu2UApmKfRjuNsTBqZcRxB-m3inZR4D90P759cMOFA@mail.gmail.com>
References: <20170530093812.10712-1-fw@strlen.de> <87y3tcj3n7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
        netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:39659 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751034AbdEaUV0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 16:21:26 -0400
In-Reply-To: <87y3tcj3n7.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31 May 2017 at 11:13, Eric W. Biederman <ebiederm@xmission.com> wrote:
> Florian Westphal <fw@strlen.de> writes:
>
>> Quoting Joe Stringer:
>>   If a user loads nf_conntrack_ftp, sends FTP traffic through a network
>>   namespace, destroys that namespace then unloads the FTP helper module,
>>   then the kernel will crash.
>>
>> Events that lead to the crash:
>> 1. conntrack is created with ftp helper in netns x
>> 2. This netns is destroyed
>> 3. netns destruction is scheduled
>> 4. netns destruction wq starts, removes netns from global list
>> 5. ftp helper is unloaded, which resets all helpers of the conntracks
>> via for_each_net()
>>
>> but because netns is already gone from list the for_each_net() loop
>> doesn't include it, therefore all of these conntracks are unaffected.
>>
>> 6. helper module unload finishes
>> 7. netns wq invokes destructor for rmmod'ed helper
>>
>> CC: "Eric W. Biederman" <ebiederm@xmission.com>
>> Reported-by: Joe Stringer <joe@ovn.org>
>> Signed-off-by: Florian Westphal <fw@strlen.de>
>> ---
>>  Eric, I'd like an explicit (n)ack from you for this one.
>
> This doesn't look too scary but I have the impression we have addressed
> this elsewhere with a different solution.
>
> Looking...
>
> Ok.  unregister_pernet_operations takes the net_mutex and thus
> gives you this barrier automatically.
>
> Hmm.  Why isn't this working for conntrack, looking...
>
> nf_conntrack_ftp doesn't use unregister_pernet_operations...
> nf_conntract_ftp does use nf_conntrack_helpers_unregister
>
> I think I almost see the problem.
>
> What is the per net code that stops dealing with the nf_conntract_ftp?
>
> I am trying to figure out if your netns_barrier is reasonable or if
> it treating the symptom.  I am having trouble seeing enough of what
> conntrack is doing to judge.
>
> Am I correct in understanding that the root problem is there is
> something pointing to ftp_exp_policy at the time of module unload?

I believe it's just that there is a conntrack entry with a 'struct
nf_conn_help' whose 'helper' parameter is pointing to the 'struct
nf_conntrack_helper ftp[...]' that is declared immediately above the
ftp_exp_policy. nf_ct_helper_destroy() would expect that
nfct_help(ct)->helper is NULL if the module was unloaded, but because
the netns was removed from the global list prior to unloading the FTP
module, there was no way to clear it. So, when the netns workqueue
invokes the destruction of all conntrack entries in the namespace, it
calls down to delete each conntrack entry and the ones with helpers
attached point to the now-unloaded helper module.

If I follow correctly, the approach proposed in the patch here ensures that:

1) nf_conntrack_helper_unregister() disengages the helper so it won't
be attached to new connections.
2) nf_conntrack_helper_unregister() clears the expectations for this helper.
3) nf_ct_iterate_destroy() iterates through all namespaces to clear
per-netns unconfirmed lists so they don't have any references to the
helper.
4) (NEW) we barrier on net_mutex to ensure that any concurrent netns
workqueue deletion which may have removed a netns prior to (3) will
finish. Now we know that we have iterated all net namespaces.
5) Iterate through the conntrack table, applying the 'unhelp'
operation to all conntrack entries. This removes the helper from all
entries while leaving the entries in the table.

Once this is all done, the helper module can finally unload.

FWIW, the previous iteration is here:
https://www.mail-archive.com/netdev@vger.kernel.org/msg109343.html

Joe
