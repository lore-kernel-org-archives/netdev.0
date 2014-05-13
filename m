From: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next 4/5] ieee802154: don't
 ignore "to" argument in unbound dgram sendmsg
Date: Tue, 13 May 2014 22:25:06 +0200
Message-ID: <b1cd7e87ad545c6f4c724b93051341ad.squirrel@webmail.itwm.fhg.de>
References: <1400001846-5349-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
    <1400001846-5349-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
    <20140513201340.GB12817@ws>
Reply-To: phoebe.buckheister@itwm.fraunhofer.de
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net
To: "Werner Almesberger" <werner@almesberger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:51125 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754981AbaEMUZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 16:25:11 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s4DKP8AB022229
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 13 May 2014 22:25:09 +0200
In-Reply-To: <20140513201340.GB12817@ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 10:13 pm, Werner Almesberger wrote:
> Phoebe Buckheister wrote:
>> For some reason, unconnected 802.15.4 dgram sockets ignore the
>> destination
>> argument of sendmsg(), while bound sockets use it. Instead, send packets
>> to the destination given by the user, and default to the connected
>> destination only if no explicit target is given.
>
> We discussed this a bit on IRC. Here's what I think happened and what
> happens with your patch. Before:
>
> conn'ed	msg_nam	action
> -------	-------	------------------------------------------
> no	no	send to initialization value (= broadcast)
> no	yes	idem
> yes	no	send to connected address
> yes	yes	idem
>
> After your patch:
>
> conn'ed	msg_nam	action
> -------	-------	------------------------------------------
> no	no	send to initialization value (= broadcast)
> no	yes	send to msg_name
> yes	no	send to connected address
> yes	yes	send to msg_name
>
> This is certainly more correct. Blurting out a broadcast in the
> no/no case isn't nice, though. It would be better to return either
> ENOTCONN (POSIX [1]) or (even better, according to GNU libc [2])
> EDESTADDRREQ.
>
> POSIX [1] says we may get EISCONN in the yes/yes case and the Linux
> man page [3] says we either get EISCONN or the msg_name argument is
> ignored. So that also doesn't look quite right yet.

You're completely right. I left the ENOTCONN case out on purpose and
forgot EISCONN, but as you listed, sendmsg() really never worked except in
one special case, and there's a bit of other nastiness going on in those
sockets. I'll revise this patch and add another to fix the rest.

>
> - Werner
>
> [1] http://pubs.opengroup.org/onlinepubs/007904975/
> [2] http://www.gnu.org/software/libc/manual/html_node/Error-Codes.html
> [3] man sendmsg
>
