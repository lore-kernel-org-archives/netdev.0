From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 12 May 2008 20:56:16 -0700
Message-ID: <d1c2719f0805122056ib4c1af7pfa7f95f6e38c7e32@mail.gmail.com>
References: <d1c2719f0805072033u38dfffaes71aed3efbc8035c0@mail.gmail.com>
	 <d1c2719f0805121522g4767f585h4b33790318f44264@mail.gmail.com>
	 <20080512.152900.220913361.davem@davemloft.net>
	 <20080512.153114.163063885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:55557 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754578AbYEMD4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 23:56:22 -0400
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id m4D3uIA0006334
	for <netdev@vger.kernel.org>; Tue, 13 May 2008 04:56:18 +0100
Received: from hs-out-0708.google.com (hsn23.prod.google.com [10.44.14.23])
	by zps18.corp.google.com with ESMTP id m4D3uH3F017890
	for <netdev@vger.kernel.org>; Mon, 12 May 2008 20:56:17 -0700
Received: by hs-out-0708.google.com with SMTP id 23so2011927hsn.13
        for <netdev@vger.kernel.org>; Mon, 12 May 2008 20:56:17 -0700 (PDT)
In-Reply-To: <20080512.153114.163063885.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2008 at 3:31 PM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
>  Date: Mon, 12 May 2008 15:29:00 -0700 (PDT)
>
>
>  > Simply notice, when we're about to decrement in_flight, that the data
>  > reference is one.  You can take appropriate actions if so.
>
>  Actually, there is an even simpler solution.  Since this is a fast
>  clone, when the parent SKB is freed we can see if the fast-clone child
>  is active and has the in_flight atomic_t pointer.  If so, we decrement
>  in_flight and zap it to NULL.

I thought about that too. But what happens if the clone is being freed by
the driver at the same time when TCP is freeing the parent? Isn't there an
intrinsic race condition here? If true, can we use some atomic operation to
zap in_flight, but also return to the caller if in_flight has been nullified
already so that the accounting can be handled correctly? (Although
tp->host_inflight doesn't need to be super accurate, if there is no simple
solution above I'll have to reset tp->host_inflight periodically and convince
myself the pathological case of host_inflight drifting forever won't ever
happen...)

Jerry
