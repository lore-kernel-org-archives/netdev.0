From: Dongpo Li <lidongpo@hisilicon.com>
Subject: question about function igmp_stop_timer() in net/ipv4/igmp.c
Date: Mon, 24 Oct 2016 19:50:12 +0800
Message-ID: <580DF574.6070905@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:18714 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757230AbcJXLve (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 07:51:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

We encountered a multicast problem when two set-top box(STB) join the same multicast group and leave.
The two boxes can join the same multicast group
but only one box can send the IGMP leave group message when leave,
the other box does not send the IGMP leave message.
Our boxes use the IGMP version 2.

I added some debug info and found the whole procedure is like this:
(1) Box A joins the multicast group 225.1.101.145 and send the IGMP v2 membership report(join group).
(2) Box B joins the same multicast group 225.1.101.145 and also send the IGMP v2 membership report(join group).
(3) Box A receives the IGMP membership report from Box B and kernel calls igmp_heard_report().
    This function will call igmp_stop_timer(im).
    In function igmp_stop_timer(im), it tries to delete IGMP timer and does the following:
        im->tm_running = 0;
        im->reporter = 0;
(4) Box A leaves the multicast group 225.1.101.145 and kernel calls
    ip_mc_leave_group -> ip_mc_dec_group -> igmp_group_dropped.
    But in function igmp_group_dropped(), the im->reporter is 0, so the kernel does not send the IGMP leave message.

I think there may be some problem in step (3).
The function igmp_stop_timer(im) should not set im->reporter to 0 if the IGMP timer has expired.
It should only work if the IGMP timer is running and does not send the IGMP join message.
I'm not sure whether it's a problem and hope any advice.

Thanks!


    Regards,
    Dongpo

.
