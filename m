From: Philip Love <love_phil@emc.com>
Subject: incorrect tcp options with window scale
Date: Fri, 22 Aug 2008 19:15:20 -0700
Message-ID: <57D3C658-5084-417D-8365-20637A3BB79B@emc.com>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from posteaux1.caltech.edu ([131.215.239.119]:36185 "EHLO
	mail.alumni.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbYHWCh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 22:37:27 -0400
Received: from [192.168.0.188] (adsl-69-230-77-203.dsl.irvnca.pacbell.net [69.230.77.203])
	by mail.alumni.caltech.edu (Postfix) with ESMTP id 26B8C3F094C
	for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 19:15:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Attached is a patch against the latest 2.6.27-rc4 kernel.

When window scaling is enabled, but the tcp buffer sizes are small,  
then the tcp SYN packet created will have an incorrect tcp header  
length. The tcp length is calculated assuming that the window scale  
option will be inserted into the tcp header, but since the buffer  
sizes are too small the window scale is not used. Therefore the last 4  
bytes of the options in the tcp header are left uninitialized.


This can be reproduced by first setting the following variables.

echo 8192 > /proc/sys/net/core/rmem_max
echo "4096 8192 8192" > /proc/sys/net/ipv4/tcp_rmem
echo 1 > /proc/sys/net/ipv4/tcp_window_scaling

Then use wireshark to examine the tcp options in the SYN packet of a  
newly created connection.




*** a/net/ipv4/tcp_output.c	2008-08-20 19:35:56.000000000 -0700
--- b/net/ipv4/tcp_output.c	2008-08-22 12:04:00.000000000 -0700
***************
*** 468,474 ****
  	}
  	if (likely(sysctl_tcp_window_scaling)) {
  		opts->ws = tp->rx_opt.rcv_wscale;
! 		size += TCPOLEN_WSCALE_ALIGNED;
  	}
  	if (likely(sysctl_tcp_sack)) {
  		opts->options |= OPTION_SACK_ADVERTISE;
--- 468,475 ----
  	}
  	if (likely(sysctl_tcp_window_scaling)) {
  		opts->ws = tp->rx_opt.rcv_wscale;
! 		if(opts->ws)
! 			size += TCPOLEN_WSCALE_ALIGNED;
  	}
  	if (likely(sysctl_tcp_sack)) {
  		opts->options |= OPTION_SACK_ADVERTISE;
