From: Dave Jones <davej@redhat.com>
Subject: 3.3-rc snmp6 panic
Date: Thu, 15 Mar 2012 01:25:06 -0400
Message-ID: <20120315052506.GA5974@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10870 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966Ab2COF4F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 01:56:05 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q2F5u3iw019626
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 01:56:04 -0400
Received: from gelk.kernelslacker.org (ovpn-113-49.phx2.redhat.com [10.3.113.49])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q2F5P8Mr003070
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 01:25:09 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.5) with ESMTP id q2F5P7PS008656
	for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 01:25:07 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id q2F5P6Tt008654
	for netdev@vger.kernel.org; Thu, 15 Mar 2012 01:25:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been seeing an occasional panic when I shut down my router
since I put 3.3 on there. It happens about once a week, always during
shutdown.  It wedges before I can get a good capture of the trace.
This is the best I've captured so far.. https://twitpic.com/8wh5l5
(apologies in advance for blurriness)

>From comparing the Code: line, and the objdump output, the code it's
choking on in mld_sendpack seems to be a skb_dst macro in the NF_HOOK..


        err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL, skb->dev,
    2dd9:       4c 8b 43 20             mov    0x20(%rbx),%r8
    2ddd:       e9 00 00 00 00          jmpq   2de2 <mld_sendpack+0x1b2>
static inline struct dst_entry *skb_dst(const struct sk_buff *skb)
{
        /* If refdst was not refcounted, check we still are in a 
         * rcu_read_lock section
         */
        WARN_ON((skb->_skb_refdst & SKB_DST_NOREF) &&
    2de2:       48 8b 43 58             mov    0x58(%rbx),%rax
    2de6:       a8 01                   test   $0x1,%al
    2de8:       0f 85 d2 01 00 00       jne    2fc0 <mld_sendpack+0x390>
                !rcu_read_lock_held() &&
                !rcu_read_lock_bh_held());
        return (struct dst_entry *)(skb->_skb_refdst & SKB_DST_PTRMASK);
    2dee:       48 83 e0 fe             and    $0xfffffffffffffffe,%rax
    2df2:       48 89 df                mov    %rbx,%rdi
    2df5:       ff 50 58                callq  *0x58(%rax)           <-----  BOOM


This machine is running an snmpd, for my mrtg setup, so the teardown of that
service is probably what's triggering it. But I can start/stop it in a loop
as much as I want without it happening, so maybe the kernel needs to accumulate
some state from it for a while first ?

Anyone have any ideas what's happening here ?

	Dave
