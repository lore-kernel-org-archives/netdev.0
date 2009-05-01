From: "Love, Robert W" <robert.w.love@intel.com>
Subject: RE: [RFC PATCH] qos: Limit a filter's priority to a 16 bit value
Date: Fri, 1 May 2009 16:30:49 -0700
Message-ID: <273D38FBE7C6FE46A1689FCD014A0B8B495C016A@azsmsx505.amr.corp.intel.com>
References: <20090501184242.12714.2663.stgit@fritz>
 <20090501.155155.58484825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "hadi@cyberus.ca" <hadi@cyberus.ca>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12187 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753238AbZEAXau convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 19:30:50 -0400
In-Reply-To: <20090501.155155.58484825.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Robert Love <robert.w.love@intel.com>
> Date: Fri, 01 May 2009 11:42:42 -0700
> 
>> Currently the kernel is storing the priority value for
>> a filter as a 32 bit value. However, the netlink messages
>> between the kernel and userspace are passing only 16 bits
>> for the priority. This means that the kernel will always
>> try to compare the passed down filter's priority using the
>> correct upper 16 bits, but all 0s for the lower 16 bits.
>> 
>> Most comparisons will fail when checking against the filter
>> chain unless the actual filter has a priority with all 0s for the
>> last 16 bits. 
>> 
>> The fallout is that users cannot modify or delete most
>> filters that are added.
> 
> Really?
> 
> I'm looking at the code and I don't see this failure case.
> Can you describe the problem with specific examples?
> 
Sure.

I should be more clear by saying that this should only
fail with filter priorities assigned by the kernel.
I think if the user passes down the priority when
creating the filter it should always be 16bits and it's
fine.

However, when the kernel is assigning priorities, the
first assigned priority for a filter is 0xC0000000,
the second is "the lowest priority - 1" so 0xBFFFFFFF.

It will assign this value in tcf_auto_prio() which will
directly assign the 32bit value to to tp->prio with-

tp->prio = nprio ? : tcf_auto_prio(*back);

(nprio == 0, since it wasn't specified by the user)

static inline u32 tcf_auto_prio(struct tcf_proto *tp)
{
 	u32 first = TC_H_MAKE(0xC0000000U, 0U);
	if (tp)
                first = tp->prio-1;
	return first;
}

If you want to delete that second filter, you'll use
tc to query the filter list to determine the priority.

The kernel will take the 32 bit 'prio' member of 'struct
tcf_proto' (which is 0xBFFFFFFF) and use the TC_H_MAJ
macro to zero-out the lower 16 bits (so that it can
fit into the top half of the 'tcm_info' member of
'struct tcmsg'). This has already mangled the priority
as we're now telling the user that the priority of the
filter is 0xBFFF0000, when in fact it is 0xBFFFFFFF.

The user will then pass this back down to the kernel to
delete the filter, however in tc_ctl_tfilter() we're
comapring 0xBFFF0000 against 0xBFFFFFFF and it never
matches.

Here's my userspace output (this is going to look ugly)-

[root@itchy ~]# tc qdisc add dev eth3 root handle 0: multiq

[root@itchy ~]# tc filter add dev eth3 parent 0: protocol 35078 handle 0x3003039 basic match 'cmp(u16' at 12 layer 1 mask 0xffff eq '35078)' action skbedit queue_mapping 3

[root@itchy ~]# tc filter add dev eth3 parent 0: protocol 35092 handle 0x3010932 basic match 'cmp(u16' at 12 layer 1 mask 0xffff eq '35092)' action skbedit queue_mapping 3

[root@itchy ~]# tc filter show dev eth3
filter parent 8002: protocol [35092] pref 49151 basic 
filter parent 8002: protocol [35092] pref 49151 basic handle 0x3010932 
  cmp(u16 at 12 layer 1 mask 0xffff eq 35092)

	action order 1:  skbedit queue_mapping 3
filter parent 8002: protocol [35078] pref 49152 basic 
filter parent 8002: protocol [35078] pref 49152 basic handle 0x3003039 
  cmp(u16 at 12 layer 1 mask 0xffff eq 35078)

	action order 33:  skbedit queue_mapping 3

[root@itchy ~]# tc filter delete dev eth3 parent 8002: protocol 35092 pref 49151 handle 0x3010932 basic match 'cmp(u16' at 12 layer 1 mask 0xffff eq '35092)' action skbedit queue_mapping 3

RTNETLINK answers: No such file or directory
We have an error talking to the kernel


You can see that the kernel would be storing 0xBFFFFFFF
with tp->prio = nprio ? : tcf_auto_prio(*back);

But the 'show' query shows the prio as 49151 (0xBFFF)
which is passed down with the 'delete' command, expanded
to 0xBFFF0000, and doesn't match the filter's actual
priority.

> All of the code I see either 1) uses u32's to store the
> priorities and just compares them (cls_u32.c) or 2)
> always uses TC_H_MAJ() of the user's provided value
> and uses that to compare with tp->prio values.
> 
> Both of which should always just work.
> 
> We're just wasting the low 16-bits, but that shouldn't
> cause problems like the one you're describing as long
> as everyone extracts and compares the top bits properly
> which as far as I can tell is the case.

