From: Al Viro <viro@ftp.linux.org.uk>
Subject: [RFC] potential bugs in nexten
Date: Sun, 23 Dec 2007 20:01:04 +0000
Message-ID: <E1J6X0S-0007Sb-AQ@ZenIV.linux.org.uk>
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:52236 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbXLWUBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 15:01:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* what are default: doing in netxen_nic_hw_write_wx()/netxen_nic_hw_read_wx()?
Unlike all other cases they do iomem->iomem copying and AFAICS they are never
actually triggered.

* netxen_nic_flash_print() reads the entire user_info from card *in* *host-endian*,
then uses user_info.serial_number[].
	a) do we need to read the rest?
	b) more interesting question, don't we need cpu_to_le32() here?  After
all, that sucker is an array of char, so we want it in the same order regardless
of the host...

* in netxen_nic_xmit_frame() we do
	hw->cmd_desc_head[saved_producer].flags_opcode =
		cpu_to_le16(hw->cmd_desc_head[saved_producer].flags_opcode);
	hw->cmd_desc_head[saved_producer].num_of_buffers_total_length =
	  cpu_to_le32(hw->cmd_desc_head[saved_producer].
			  num_of_buffers_total_length);
Huh?  Everything that modifies either of those does so in little-endian already.
This code appeared in commit 6c80b18df3537d1221ab34555c150bccbfd90260 (NetXen:
Port swap feature for multi port cards); what's going on there?

