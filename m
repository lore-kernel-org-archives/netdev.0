From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: [BUG] af_packet: tpacket_destruct_skb throws BUG under high tx load
Date: Mon, 6 Aug 2012 13:21:01 +0200
Message-ID: <CAD6jFUSvcfGjARfF_ysbCF1CXUL1Xzo2sU2aHuVnwd9+tBL_0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51256 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755998Ab2HFLtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 07:49:40 -0400
Received: from [78.46.5.204] (helo=sslproxy02.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1SyLMy-00051Z-UH
	for netdev@vger.kernel.org; Mon, 06 Aug 2012 13:21:08 +0200
Received: from [209.85.214.174] (helo=mail-ob0-f174.google.com)
	by sslproxy02.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1SyLLf-00021C-90
	for netdev@vger.kernel.org; Mon, 06 Aug 2012 13:19:47 +0200
Received: by obbuo13 with SMTP id uo13so5743704obb.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 04:21:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under high tx load from mmap()ed PF_PACKET sockets the statement in
tpacket_destruct_skb():

  BUG_ON(__packet_get_status(po, ph) != TP_STATUS_SENDING);

is being thrown, where __packet_get_status(po, ph) has the value
TP_STATUS_SEND_REQUEST instead of TP_STATUS_SENDING.

The send(2) system call was invoked with the flag MSG_DONTWAIT. The
BUG occurred even with having dev_queue_xmit() returned successfully
in tpacket_snd().

By simply removing this BUG statement, the system seemed stable, but
this might not be the proper solution. It's reproducible and I tested
it on a multi-core system  under the latest net/net-next kernel on x86
and x86_64.

On my system, this BUG was triggered in the following cases:

* Multiple processes allocate and use a TX_RING on one device

* A single process allocates a TX_RING on one device and
/proc/sys/net/core/wmem_default, /proc/sys/net/core/wmem_max were
increased

Cheers,

Daniel
