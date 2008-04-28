From: "Tom Herbert" <therbert@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 28 Apr 2008 10:51:12 -0700
Message-ID: <65634d660804281051i1ce3deb1m626bb9b64473b536@mail.gmail.com>
References: <65634d660804242234w66455bedve44801a98e3de9d9@mail.gmail.com>
	 <20080424.233643.250240829.davem@davemloft.net>
	 <65634d660804250042y5786e305t456f2154a6bcf040@mail.gmail.com>
	 <20080425.004634.27450322.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, johnwheffner@gmail.com, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:33995 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934430AbYD1RvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 13:51:16 -0400
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id m3SHpD2G005236
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 18:51:13 +0100
Received: from py-out-1112.google.com (pybu52.prod.google.com [10.34.97.52])
	by spaceape14.eur.corp.google.com with ESMTP id m3SHo8K9011279
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 18:51:12 +0100
Received: by py-out-1112.google.com with SMTP id u52so5144502pyb.1
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 10:51:12 -0700 (PDT)
In-Reply-To: <20080425.004634.27450322.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  > If NIC is interrupt driven, enough data must be queued to span
>  > consecutive interrupts.  So for instance if a 10G NIC is generating an
>  > interrupt every 100us, about 125,000 bytes needs to queued at each
>  > interrupt to prevent starvation-- this doesn't translate to a fixed
>  > number of packets.  Limiting by packets seems somewhat ad hoc; if the
>  > limit is to small and the link will be starved, too big and
>  > over-queuing results.
>
>  Yes, however when packets are small the limiting factor becomes
>  per-transfer transaction related overhead.
>

The gist of our algorithm is to determine when the device has been
starved (ie. when all packets queued to the device have been sent, and
there are packets ready in host queues).  When the device is starved,
the byte limit is increased by some amount; if the device is not
starved, the byte limit is decreased by an amount subject to some
mechanisms to prevent hysteresis.  If throughput is less than line
rate, because of small packets for example, the byte limit will
decrease accordingly since fewer packets are needed to be queued to
prevent starvation.  This algorithm requires no a priori knowledge of
link speed or interrupt rate, it will adjust the byte queue limit to
such variable parameters.
