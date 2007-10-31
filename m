From: Patrick McHardy <kaber@trash.net>
Subject: af_packet.c flush_dcache_page
Date: Wed, 31 Oct 2007 15:08:02 +0100
Message-ID: <47288C42.5010603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57821 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755107AbXJaOKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 10:10:49 -0400
Received: from [192.168.0.100] (unknown [87.234.154.23])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTP id 63995948A5
	for <netdev@vger.kernel.org>; Wed, 31 Oct 2007 15:10:48 +0100 (MET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm currently adding mmap support to af_netlink based on the
af_packet implementation and I'm wondering about this code in
tpacket_rcv():

         h->tp_status = status;
         smp_mb();

         {
                 struct page *p_start, *p_end;
                 u8 *h_end = (u8 *)h + macoff + snaplen - 1;

                 p_start = virt_to_page(h);
                 p_end = virt_to_page(h_end);
                 while (p_start <= p_end) {
                         flush_dcache_page(p_start);
                         p_start++;
                 }
         }

Shouldn't the flushing be done in reverse order to make sure
that the page containing tp_status is flushed last and userspace
doesn't start looking at following pages before all dcache entries
are flushed?

A related question: Documentation/cachetlb.txt mentions that
flushing also needs to be done for reading of shared+writable
mapped pages, so it seems like we also need to call flush_dcache_page 
before the tp_status check earlier in that function and packet_poll().
