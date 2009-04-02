From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 10:24:39 -0400
Message-ID: <49D4CAA7.3020004@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D46089.5040204@redhat.com> <49D497A1.4090900@novell.com> <49D4A4EB.8020105@redhat.com> <49D4AE0C.3000604@novell.com> <49D4B2C0.5060906@redhat.com> <49D4B594.6080703@novell.com> <49D4B8B4.4020003@redhat.com> <49D4BF70.1060301@novell.com> <49D4C191.2070502@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig44968B625AA8866F3DD404F0"
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D4C191.2070502@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig44968B625AA8866F3DD404F0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>> Avi Kivity wrote:
>> =20
>>> Gregory Haskins wrote:
>>>   =20
>>>> Avi Kivity wrote:
>>>> =20
>>>>     =20
>>>>> My 'prohibitively expensive' is true only if you exit every packet.=

>>>>>
>>>>>
>>>>>            =20
>>>> Understood, but yet you need to do this if you want something like
>>>> iSCSI
>>>> READ transactions to have as low-latency as possible.
>>>>        =20
>>> Dunno, two microseconds is too much?  The wire imposes much more.
>>>
>>>    =20
>>
>> No, but thats not what we are talking about.  You said signaling on
>> every packet is prohibitively expensive.  I am saying signaling on eve=
ry
>> packet is required for decent latency.  So is it prohibitively expensi=
ve
>> or not?
>>  =20
>
> We're heading dangerously into the word-game area.  Let's not do that.
>
> If you have a high throughput workload with many packets per seconds
> then an exit per packet (whether to userspace or to the kernel) is
> expensive.  So you do exit mitigation.  Latency is not important since
> the packets are going to sit in the output queue anyway.

Agreed.  virtio-net currently does this with batching.  I do with the
bidir napi thing (which effectively crosses the producer::consumer > 1
threshold to mitigate the signal path).


>
> If you have a request-response workload with the wire idle and latency
> critical, then there's no problem having an exit per packet because
> (a) there aren't that many packets and (b) the guest isn't doing any
> batching, so guest overhead will swamp the hypervisor overhead.
Right, so the trick is to use an algorithm that adapts here.  Batching
solves the first case, but not the second.  The bidir napi thing solves
both, but it does assume you have ample host processing power to run the
algorithm concurrently.  This may or may not be suitable to all
applications, I admit.

>
> If you have a low latency request-response workload mixed with a high
> throughput workload, then you aren't going to get low latency since
> your low latency packets will sit on the queue behind the high
> throughput packets.  You can fix that with multiqueue and then you're
> back to one of the scenarios above.
Agreed, and thats ok.  Now we are getting more into 802.1p type MQ
issues anyway, if the application cared about it that much.

>
>> I think most would agree that adding 2us is not bad, but so far that i=
s
>> an unproven theory that the IO path in question only adds 2us.   And w=
e
>> are not just looking at the rate at which we can enter and exit the
>> guest...we need the whole path...from the PIO kick to the dev_xmit() o=
n
>> the egress hardware, to the ingress and rx-injection.  This includes a=
ny
>> and all penalties associated with the path, even if they are imposed b=
y
>> something like the design of tun-tap.
>>  =20
>
> Correct, we need to look at the whole path.  That's why the wishing
> well is clogged with my 'give me a better userspace interface' emails.
>
>> Right now its way way way worse than 2us.  In fact, at my last reading=

>> this was more like 3060us (3125-65).  So shorten that 3125 to 67 (whil=
e
>> maintaining line-rate) and I will be impressed.  Heck, shorten it to
>> 80us and I will be impressed.
>>  =20
>
> The 3060us thing is a timer, not cpu time.
Agreed, but its still "state of the art" from an observer perspective.=20
The reason "why", though easily explainable, is inconsequential to most
people.  FWIW, I have seen virtio-net do a much more respectable 350us
on an older version, so I know there is plenty of room for improvement.

>   We aren't starting a JVM for each packet.
Heh...it kind of feels like that right now, so hopefully some
improvement will at least be on the one thing that comes out of all this.=


-Greg


--------------enig44968B625AA8866F3DD404F0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknUyqcACgkQlOSOBdgZUxlvnwCfQbpR6YOBGTALnUVfz7q848FG
4XMAn2KX9zOYxS4cLIZOwSJ0zHla8cgC
=COrl
-----END PGP SIGNATURE-----

--------------enig44968B625AA8866F3DD404F0--
