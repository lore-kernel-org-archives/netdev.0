From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH] [PATCH] tcp: Increment of LINUX_MIB_LISTENOVERFLOWS in
 tcp_v4_conn_request() (updated)
Date: Sun, 27 Jan 2013 21:02:31 -0800
Message-ID: <CAGK4HS-h77PGp--hvFOPEPJu0ru5uz_K_Aqjo8k2hO=VWBr7Eg@mail.gmail.com>
References: <1359337550-3958-1-git-send-email-niveditasinghvi@gmail.com>
	<CAGK4HS9_xZSWVHBQX3DwvR7swnGqqccdD8mvL-i20a2dnOvK1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Nivedita Singhvi <niv@us.ibm.com>
To: Nivedita Singhvi <niveditasinghvi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:52149 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817Ab3A1FCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 00:02:32 -0500
Received: by mail-qa0-f49.google.com with SMTP id o13so518195qaj.15
        for <netdev@vger.kernel.org>; Sun, 27 Jan 2013 21:02:31 -0800 (PST)
In-Reply-To: <CAGK4HS9_xZSWVHBQX3DwvR7swnGqqccdD8mvL-i20a2dnOvK1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27 January 2013 18:01, Vijay Subramanian <subramanian.vijay@gmail.com> wrote:
> On 27 January 2013 17:45, Nivedita Singhvi <niveditasinghvi@gmail.com> wrote:
>> From: Nivedita Singhvi <niv@us.ibm.com>
>>
>> We drop a connection request if the accept backlog is full and there are
>> sufficient packets in the syn queue to warrant starting drops. Increment the
>> appropriate counter so this isn't silent, for accurate stats and help in
>> debugging.
>>
>> Signed-off-by: Nivedita Singhvi <niv@us.ibm.com>
>

The patch is ok but I think we missed something. Please consider the
following in
tcp_v4_syn_recv_sock()

exit_overflow:
        NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
exit_nonewsk:
        dst_release(dst);
exit:
        NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
        return NULL;
put_and_exit:
        inet_csk_prepare_forced_close(newsk);
        tcp_done(newsk);
        goto exit;


When ListenOverflows is incremented, so is ListenDrops. This is
because overflows is one of  several reasons why a SYN can be dropped
by a socket in LISTEN state. When we increment ListenOverflows, we
should also increment ListenDrops.

So we also need
NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);

Would you mind updating this?  (If you want me to do it as I acked the
patch, let me know.)

Thanks,
Vijay
