From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 5/5] tls: Add generic NIC offload infrastructure.
Date: Wed, 20 Sep 2017 17:16:13 +0200
Message-ID: <87zi9pbdtu.fsf@stressinduktion.org>
References: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
        <1505385988-94522-6-git-send-email-ilyal@mellanox.com>
        <87poaocb4q.fsf@stressinduktion.org>
        <AM4PR0501MB2723F6F5A22955102CDC2886D4600@AM4PR0501MB2723.eurprd05.prod.outlook.com>
        <87wp4vt4aa.fsf@stressinduktion.org>
        <DB6PR05MB3176E39DDA1771A6883860FBB0600@DB6PR05MB3176.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem\@davemloft.net" <davem@davemloft.net>,
        "davejwatson\@fb.com" <davejwatson@fb.com>,
        "tom\@herbertland.com" <tom@herbertland.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Liran Liss <liranl@mellanox.com>
To: Boris Pismenny <borisp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:53089 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751826AbdITPQS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 11:16:18 -0400
In-Reply-To: <DB6PR05MB3176E39DDA1771A6883860FBB0600@DB6PR05MB3176.eurprd05.prod.outlook.com>
        (Boris Pismenny's message of "Tue, 19 Sep 2017 14:02:33 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Boris Pismenny <borisp@mellanox.com> writes:

> Hello,
>
> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
>> Hello,
>> 
>> Ilya Lesokhin <ilyal@mellanox.com> writes:
>> 
>> > Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
>> >
>> >> The user should be aware of that they can't migrate the socket to
>> >> another interface if they got hw offloaded. This is not the case for
>> software offload.
>> >> Thus I think the user has to opt in and it shouldn't be a heuristic
>> >> until we can switch back to sw offload path.
>> >>
>> >> Maybe change flowi_oif to sk_bound_dev_if and somwhow lock it against
>> >> further changes if hw tls is in use?
>> >>
>> >
>> > I'm not sure I follow.
>> > We do set sk->sk_bound_dev_if to prevent further changes.
>> >
>> > Do you recommend we enable TLS offload only if SO_BINDTODEVICE
>> > was previously used on that socket?
>> > and prevent even users with CAP_NET_RAW from unbinding it?
>> >
>> > I would rather avoid requiring CAP_NET_RAW to use TLS offload.
>> > But admittedly I'm not sure setting sk->sk_bound_dev_if without
>> > CAP_NET_RAW like we do is legit either.
>> >
>> > Finally, the reason we made HW offload the default is that the user
>> > can use sudo ethtool -K enp0s4 tls-hw-tx-offload off to opt out of HW
>> > offload and we currently don't have anything equivalent for opting out of
>> SW KTLS.
>> 
>> IMHO the decision if a TCP flow should be bounded to hw and thus never
>> push traffic to another interface should a decision the administrator and the
>> application should opt in. You might have your management application
>> which is accessible over multiple interfaces and your production application
>> which might want to use hw offloaded tls. Thus I don't think only a single
>> ethtool knob will do it.
>
> IMO the configuration knob should be at the kTLS level and not at the
> HW vs. SW level. The management application shouldn't be using kTLS.
> I'd like to view TLS offload similarly to LSO. The default is opt-in if
> possible, and the Kernel decides that based on device capabilities.
>
>> 
>> I agree that SO_BINDTODEVICE is bad for this use case. First, the
>> CAP_NET_RAW limitation seems annoying and we don't want to enforce TLS
>> apps to have this capability. Second, the user space application doesn't care
>> which interface it should talk to (maybe?) but leave the routing decision to
>> the kernel and just opt in to TLS. SO_BINDTODEVICE doesn't allow this.
>> 
>> sk_bound_dev_if can be rebound later with CAP_NET_RAW privileges, will
>> this be a problem?
>
> Yes it is a problem and we have some ideas for a software fallback that should
> catch this. 

Ok.

> Is the software fallback a prerequisite for kTLS offload in Kernel?

I don't know. I would assume yes because it will change how uAPI will
look like?

>> 
>> Have you thought how the user space will configure the various offloading
>> features (sw, hw, none)? Will it in e.g. OpenSSL be part of the Cipher Spec or
>> will there be new functions around SSL_CTX to do so?
>> 
>> Maybe an enhancement of the TLS_TX setsockopt with a boolean for hw
>> offload is a solution?
>
> Yes, we think that OpenSSL should first configure whether it complies with
> kTLS support. Next, we thought of using an environment variable to control
> kTLS globally in OpenSSL as follows:

0. no kernel tls at all but use e.g. OpenSSL crypto code.

> 1. only software kTLS
> 2. only hardware kTLS - no fallback to software.
> 3. Try to use hardware kTLS and if it isn't supported fallback to
> software kTLS.

Hmm, environment variable and global control contradicts itself. ;)

In some form or another there is a need to have all options for
debugging. I also wonder if it makes sense to disable ktls based on
reordering and fast path vs. slow path hit ratio. But that is something
to think about later.

> The above is something we plan for the future, assuming that kTLS
> wouldn't fit for all use-cases. What do you think?
>
> If you'd like to have more fine-grained control of kTLS, e.g. per socket,
> then the application would need to be modified to configure that,
> which is something we try to avoid.

That is why I proposed signaling over ciphers(1) for openssl. If you
e.g. look at apache/mod_ssl, they loop the cipher list from the
configuration file directly to OpenSSL. Same for a lot of other web
servers, nginx etc. Thus you just need to modify openssl and don't need
to touch the users of the library.

E.g. in Fedora/RHEL the crypto libs load a default cipher list from
/etc/crypto-policies/, which you can update centrally with
update-crypto-policies. Maybe the kTLS switches fit nicely in there?

For that to do, OpenSSL needs still to have more fine grain control over
which kTLS sw/hw to use, right?

>> 
>> Another question:
>> 
>> How is the dependency management done between socket layer and driver
>> layer? It seems a bit cyclic but judging from this code you don't hold
>> references to the device (dev_hold) (which is good, you don't want to have
>> users creating refs to devices). OTOH you somehow need to match sockets
>> from the device layer up to the socket. Will those be reference counted or
>> does that work without?
>
> Not sure I follow your question.
> We use the socket from the device layer through the SKB that carries it,
> so I think it should work without.
> We don't attempt to perform a socket lookup or anything of this sort.

The socket from skb is only valid as long as you have the skb. Basically
the question is: do you ever increase the ref counter of sockets from
the device drivers?

Thanks,
Hannes
