From: Daniel Axtens <dja@axtens.net>
Subject: Re: [PATCH] bnx2x: drop packets where gso_size is too big for hardware
Date: Mon, 18 Sep 2017 14:41:51 +1000
Message-ID: <87fubkehyo.fsf@linkitivity.dja.id.au>
References: <20170831054642.13721-1-dja@axtens.net> <1504159341.15310.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        Yuval.Mintz@cavium.com, ariel.elior@cavium.com,
        everest-linux-l2@cavium.com, jay.vosburgh@canonical.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:48043 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750711AbdIREl5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 00:41:57 -0400
Received: by mail-pg0-f45.google.com with SMTP id d8so4385373pgt.4
        for <netdev@vger.kernel.org>; Sun, 17 Sep 2017 21:41:57 -0700 (PDT)
In-Reply-To: <1504159341.15310.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

>> +		if (unlikely(skb_shinfo(skb)->gso_size + hlen > MAX_PACKET_SIZE)) {
>> +			BNX2X_ERR("reported gso segment size plus headers "
>> +				  "(%d + %d) > MAX_PACKET_SIZE; dropping pkt!",
>> +				  skb_shinfo(skb)->gso_size, hlen);
>> +
>> +			goto free_and_drop;
>> +		}
>> +
>
>
> If you had this test in bnx2x_features_check(), packet could be
> segmented by core networking stack before reaching bnx2x_start_xmit() by
> clearing NETIF_F_GSO_MASK
>
> -> No drop would be involved.
>
> check i40evf_features_check() for similar logic.

So I've been experimenting with this and reading through the core
networking code. If my understanding is correct, disabling GSO will
cause the packet to be segmented, but it will be segemented into
gso_size+header length packets. So in this case (~10kB gso_size) the
resultant packets will still be too big - although at least they don't
cause a crash in that case.

We could continue with this anyway as it at least prevents the crash -
but, and I haven't been able to find a nice definitive answer to this -
are implementations of ndo_start_xmit permitted to assume that the the
skb passed in will fit within the MTU? I notice that most callers will
attempt to ensure this - for example ip_output.c, ip6_output.c and
ip_forward.c all contain calls to skb_gso_validate_mtu(). If
implementations are permitted to assume this, perhaps a fix to
openvswitch would be more appropriate?

Regards,
Daniel
