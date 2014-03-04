From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] audit: Simplify by assuming the callers socket buffer is large enough
Date: Tue, 04 Mar 2014 14:41:16 -0800
Message-ID: <87mwh5d1tf.fsf@xmission.com>
References: <874n3ir0uw.fsf_-_@xmission.com> <87mwhaplo4.fsf_-_@xmission.com>
	<20140304133004.b565820f60f595a48e621e58@linux-foundation.org>
	<20140304.165122.445822929490466603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: akpm@linux-foundation.org, rgb@redhat.com, eparis@redhat.com,
	linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140304.165122.445822929490466603.davem@davemloft.net> (David
	Miller's message of "Tue, 04 Mar 2014 16:51:22 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Tue, 4 Mar 2014 13:30:04 -0800
>
>> On Fri, 28 Feb 2014 20:50:19 -0800 ebiederm@xmission.com (Eric W. Biederman) wrote:
>> 
>>> 
>>> Modify audit_send_reply to directly use a non-blocking send and
>>> to return an error on failure (if anyone cares).
>>> 
>>> Modify audit_list_rules_send to use audit_send_reply and give up
>>> if we can not send a packet.
>>> 
>>> Merge audit_list_rules into iaudit_list_rules_send as the code
>>> is now sufficiently simple to not justify to callers.
>>> 
>>> Kill audit_send_list, audit_send_reply_thread because using
>>> a separate thread for replies is not needed when sending
>>> packets syncrhonously.
>> 
>> Nothing much seems to be happening here?

Well you picked up the patch that fixes the worst of the bugs that I was
complaining about.  Beyond that I don't know what makes sense.

>> In an earlier email you said "While reading through 3.14-rc1 I found a
>> pretty siginficant mishandling of network namespaces in the recent
>> audit changes." Were those recent audit changes a post-3.14 thing?  And
>> what is the user-visible effect of the mishandling?
>
> I took a quick look at this patch yesterday, and my only suspicion is
> that threads are created currently by this code purely to cons up a
> blockable context for the netlink code.
>
> Perhaps it wants to avoid any netlink packet drops from being possible.
>
> I'm not so sure.

Looking at the history (see below) the stated reason from David
Woodhouse is to prevent the removal of packets from the packet queues
when we have reached our rcvbuf limit.

The reasoning doesn't make a lick of sense to me and I was hoping the
folks dealing with audit would comment.

If we really want the ability to always appened to the queue of skb's
is to just have a version of netlink_send_skb that ignores the queued
limits.  Of course an evil program then could force the generation of
enough audit records to DOS the kernel, but we seem to be in that
situation now.  Shrug.

> Anyways, some investigation into perhaps figuring out the intentions of
> the original implementation would be nice.

I had looked briefly and missed a few things.  Here is the complete
history in all of it's confusion.

In brief.  The code came in using non-blocking netlink writes.

David Woodhouse made the writes blocking.

Al Viro, and then Eric Paris patch the code to deal with deadlocks
cause by the blocking writes.


commit 4527a30f157fca45c102ea49a2fb34a4502264eb
Author: akpm <akpm>
Date:   Mon Apr 12 20:29:12 2004 +0000

    [PATCH] Light-weight Auditing Framework
    
    From: Rik Faith <faith@redhat.com>
    
    This patch provides a low-overhead system-call auditing framework for Linux
    that is usable by LSM components (e.g., SELinux).  This is an update of the
    patch discussed in this thread:
    
        http://marc.theaimsgroup.com/?t=107815888100001&r=1&w=2
    
    In brief, it provides for netlink-based logging of audit records that have
    been generated in other parts of the kernel (e.g., SELinux) as well as the
    ability to audit system calls, either independently (using simple
    filtering) or as a compliment to the audit record that another part of the
    kernel generated.
    
    The main goals were to provide system call auditing with 1) as low overhead
    as possible, and 2) without duplicating functionality that is already
    provided by SELinux (and/or other security infrastructures).  This
    framework will work "stand-alone", but is not designed to provide, e.g.,
    CAPP functionality without another security component in place.
    
    This updated patch includes changes from feedback I have received,
    including the ability to compile without CONFIG_NET (and better use of
    tabs, so use -w if you diff against the older patch).
    
    Please see http://people.redhat.com/faith/audit/ for an early example
    user-space client (auditd-0.4.tar.gz) and instructions on how to try it.
    
    My future intentions at the kernel level include improving filtering (e.g.,
    syscall personality/exit codes) and syscall support for more architectures.
     First, though, I'm going to work on documentation, a (real) audit daemon,
    and patches for other user-space tools so that people can play with the
    framework and understand how it can be used with and without SELinux.
    
    
    Update:
    
    Light-weight Auditing Framework receive filter fixes
    From: Rik Faith <faith@redhat.com>
    
    Since audit_receive_filter() is only called with audit_netlink_sem held, it
    cannot race with either audit_del_rule() or audit_add_rule(), so the
    list_for_each_entry_rcu()s may be replaced by list_for_each_entry()s, and
    the rcu_read_{un,}lock()s removed.  A fix for this is part of the attached
    patch.
    
    Other features of the attached patch are:
    
    1) generalized the ability to test for inequality
   
    2) added syscall exit status reporting and testing
    
    3) added ability to report and test first 4 syscall arguments (this adds
       a large amount of flexibility for little cost; not implemented or tested
       on ppc64)
    
    4) added ability to report and test personality
    
    User-space demo program enhanced for new fields and inequality testing:
    http://people.redhat.com/faith/audit/auditd-0.5.tar.gz
    
    BKrev: 407afc18IAH0yJVxEhi5ka-sbTOn8g

diff --git a/kernel/audit.c b/kernel/audit.c
new file mode 100644
index 000000000000..765822b03b91
--- /dev/null
+++ b/kernel/audit.c
[snip]
+void audit_send_reply(int pid, int seq, int type, int done, int multi,
+                     void *payload, int size)
+{
+       struct sk_buff  *skb;
+       struct nlmsghdr *nlh;
+       int             len = NLMSG_SPACE(size);
+       void            *data;
+       int             flags = multi ? NLM_F_MULTI : 0;
+       int             t     = done  ? NLMSG_DONE  : type;
+
+       skb = alloc_skb(len, GFP_KERNEL);
+       if (!skb)
+               goto nlmsg_failure;
+
+       nlh              = NLMSG_PUT(skb, pid, seq, t, len - sizeof(*nlh));
+       nlh->nlmsg_flags = flags;
+       data             = NLMSG_DATA(nlh);
+       memcpy(data, payload, size);
+       netlink_unicast(audit_sock, skb, pid, MSG_DONTWAIT);
+       return;
+
+nlmsg_failure:                 /* Used by NLMSG_PUT */
+       if (skb)
+               kfree_skb(skb);
+}


commit b7d1125817c9a46cc46f57db89d9c195e7af22f8
Author: David Woodhouse <dwmw2@shinybook.infradead.org>
Date:   Thu May 19 10:56:58 2005 +0100

    AUDIT: Send netlink messages from a separate kernel thread
    
    netlink_unicast() will attempt to reallocate and will free messages if
    the socket's rcvbuf limit is reached unless we give it an infinite
    timeout. So do that, from a kernel thread which is dedicated to spewing
    stuff up the netlink socket.
    
    Signed-off-by: David Woodhouse <dwmw2@infradead.org>
@@ -293,13 +319,16 @@ void audit_send_reply(int pid, int seq, int type, int done, int multi,
 
        skb = alloc_skb(len, GFP_KERNEL);
        if (!skb)
-               goto nlmsg_failure;
+               return;
 
-       nlh              = NLMSG_PUT(skb, pid, seq, t, len - sizeof(*nlh));
+       nlh              = NLMSG_PUT(skb, pid, seq, t, size);
        nlh->nlmsg_flags = flags;
        data             = NLMSG_DATA(nlh);
        memcpy(data, payload, size);
-       netlink_unicast(audit_sock, skb, pid, MSG_DONTWAIT);
+
+       /* Ignore failure. It'll only happen if the sender goes away,
+          because our timeout is set to infinite. */
+       netlink_unicast(audit_sock, skb, pid, 0);
        return;
 
 nlmsg_failure:                 /* Used by NLMSG_PUT */


commit 9044e6bca5a4a575d3c068dfccb5651a2d6a13bc
Author: Al Viro <viro@zeniv.linux.org.uk>
Date:   Mon May 22 01:09:24 2006 -0400

    [PATCH] fix deadlocks in AUDIT_LIST/AUDIT_LIST_RULES
    
    We should not send a pile of replies while holding audit_netlink_mutex
    since we hold the same mutex when we receive commands.  As the result,
    we can get blocked while sending and sit there holding the mutex while
    auditctl is unable to send the next command and get around to receiving
    what we'd sent.
    
    Solution: create skb and put them into a queue instead of sending;
    once we are done, send what we've got on the list.  The former can
    be done synchronously while we are handling AUDIT_LIST or AUDIT_LIST_RULES;
    we are holding audit_netlink_mutex at that point.  The latter is done
    asynchronously and without messing with audit_netlink_mutex.
    
    Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

commit f09ac9db2aafe36fde9ebd63c8c5d776f6e7bd41
Author: Eric Paris <eparis@redhat.com>
Date:   Fri Apr 18 10:11:04 2008 -0400

    Audit: stop deadlock from signals under load
    
    A deadlock is possible between kauditd and auditd under load if auditd
    receives a signal.  When auditd receives a signal it sends a netlink
    message to the kernel asking for information about the sender of the
    signal.  In that same context the audit system will attempt to send a
    netlink message back to the userspace auditd.  If kauditd has already
    filled the socket buffer (see netlink_attachskb()) auditd will now put
    itself to sleep waiting for room to send the message.  Since auditd is
    responsible for draining that socket we have a deadlock.  The fix, since
    the response from the kernel does not need to be synchronous is to send
    the signal information back to auditd in a separate thread.  And thus
    auditd can continue to drain the audit queue normally.
    
    Signed-off-by: Eric Paris <eparis@redhat.com>
    Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>




Eric
