From: Tina Yang <tina.yang@oracle.com>
Subject: netconsole problems
Date: Thu, 04 Oct 2007 10:59:38 -0700
Message-ID: <47052A0A.2080100@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Matt Mackall <mpm@selenic.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:37145 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756500AbXJDSDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 14:03:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We recently run into a few problems with netconsole
in at least 2.6.9, 2.6.18 and 2.6.23.  It either panicked
at netdevice.h:890 or hung the system, and sometimes depending
on which NIC we are using, the following console message,
 e1000:
      "e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang"
 tg3:
      "NETDEV WATCHDOG: eth4: transmit timed out"
      "tg3: eth4: transmit timed out, resetting"

The postmortem vmcore analysis indicated race between normal
network stack (net_rx_action) and netpoll, and disabling the
following code segment cures all the problems.

netpoll.c
    178         /* Process pending work on NIC */
    179         np->dev->poll_controller(np->dev);
    180         if (np->dev->poll)
    181                 poll_napi(np);

Big or small, there seems to be several race windows in the code,
and fixing them probably has consequence on overall system performance.
Maybe this code should only run when the machine is single-threaded ?
Suggestions ?  Thanks.

