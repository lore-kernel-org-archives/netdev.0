From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 5/5] tls: Add generic NIC offload infrastructure.
Date: Tue, 19 Sep 2017 11:40:29 +0200
Message-ID: <87wp4vt4aa.fsf@stressinduktion.org>
References: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
        <1505385988-94522-6-git-send-email-ilyal@mellanox.com>
        <87poaocb4q.fsf@stressinduktion.org>
        <AM4PR0501MB2723F6F5A22955102CDC2886D4600@AM4PR0501MB2723.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem\@davemloft.net" <davem@davemloft.net>,
        "davejwatson\@fb.com" <davejwatson@fb.com>,
        "tom\@herbertland.com" <tom@herbertland.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Liran Liss <liranl@mellanox.com>
To: Ilya Lesokhin <ilyal@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:60069 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751024AbdISJkd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 05:40:33 -0400
In-Reply-To: <AM4PR0501MB2723F6F5A22955102CDC2886D4600@AM4PR0501MB2723.eurprd05.prod.outlook.com>
        (Ilya Lesokhin's message of "Tue, 19 Sep 2017 07:36:28 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Ilya Lesokhin <ilyal@mellanox.com> writes:

> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
>
>> The user should be aware of that they can't migrate the socket to another
>> interface if they got hw offloaded. This is not the case for software offload.
>> Thus I think the user has to opt in and it shouldn't be a heuristic until we can
>> switch back to sw offload path.
>> 
>> Maybe change flowi_oif to sk_bound_dev_if and somwhow lock it against
>> further changes if hw tls is in use?
>> 
>
> I'm not sure I follow.
> We do set sk->sk_bound_dev_if to prevent further changes.
>
> Do you recommend we enable TLS offload only if SO_BINDTODEVICE	
> was previously used on that socket?
> and prevent even users with CAP_NET_RAW from unbinding it?
>
> I would rather avoid requiring CAP_NET_RAW to use TLS offload. 
> But admittedly I'm not sure setting sk->sk_bound_dev_if 
> without CAP_NET_RAW like we do is legit either.
>
> Finally, the reason we made HW offload the default is that the user
> can use sudo ethtool -K enp0s4 tls-hw-tx-offload off to opt out of HW offload
> and we currently don't have anything equivalent for opting out of SW KTLS.

IMHO the decision if a TCP flow should be bounded to hw and thus never
push traffic to another interface should a decision the administrator
and the application should opt in. You might have your management
application which is accessible over multiple interfaces and your
production application which might want to use hw offloaded tls. Thus I
don't think only a single ethtool knob will do it.

I agree that SO_BINDTODEVICE is bad for this use case. First, the
CAP_NET_RAW limitation seems annoying and we don't want to enforce TLS
apps to have this capability. Second, the user space application doesn't
care which interface it should talk to (maybe?) but leave the routing
decision to the kernel and just opt in to TLS. SO_BINDTODEVICE doesn't
allow this.

sk_bound_dev_if can be rebound later with CAP_NET_RAW privileges, will
this be a problem?

Have you thought how the user space will configure the various
offloading features (sw, hw, none)? Will it in e.g. OpenSSL be part of
the Cipher Spec or will there be new functions around SSL_CTX to do so?

Maybe an enhancement of the TLS_TX setsockopt with a boolean for hw
offload is a solution?

Another question:

How is the dependency management done between socket layer and driver
layer? It seems a bit cyclic but judging from this code you don't hold
references to the device (dev_hold) (which is good, you don't want to
have users creating refs to devices). OTOH you somehow need to match
sockets from the device layer up to the socket. Will those be reference
counted or does that work without?

Thanks,
Hannes
