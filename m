From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: New module infrastructure for net_proto_family
Date: Mon, 28 Apr 2003 22:43:26 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429014326.GA24835@conectiva.com.br>
References: <20030424230202.GB2931@conectiva.com.br> <5.1.0.14.2.20030424094431.080b5320@unixmail.qualcomm.com> <5.1.0.14.2.20030423134636.100e5c60@unixmail.qualcomm.com> <5.1.0.14.2.20030423114915.10840678@unixmail.qualcomm.com> <5.1.0.14.2.20030423114915.10840678@unixmail.qualcomm.com> <5.1.0.14.2.20030423134636.100e5c60@unixmail.qualcomm.com> <5.1.0.14.2.20030424094431.080b5320@unixmail.qualcomm.com> <5.1.0.14.2.20030428130220.10644ee0@unixmail.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Max Krasnyansky <maxk@qualcomm.com>
Content-Disposition: inline
In-Reply-To: <5.1.0.14.2.20030428130220.10644ee0@unixmail.qualcomm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Mon, Apr 28, 2003 at 02:10:11PM -0700, Max Krasnyansky escreveu:
> Hi Arnaldo,
> 
> Hmm, no comments on my last email (http://marc.theaimsgroup.com/?l=linux-netdev&m=105123134301565&w=2) 
> Are you trying to ignore me too ? ;-)

Nope, I was working on the higher layer first, to then come to the net families
that are already modular and have per-protocol modules, and I'm starting to look
into the only, AFAIK, network family that has this in place: bluetooth :-)

Having said that I haven't fully studied this I see two scenarios (brainstorming):

1. the net family that wants per protocol "sub" modules "duplicates" the
infrastructure having PROTO_sk_alloc and PROTO_destruct (the sk_free
sk->destruct hook call), PROTO_sk_alloc uses its net_families equivalent
(bt_proto in bluetooth) to find the owner (the "sub" module, i.e. per protocol
module) and PROTO_net_family_gets it, then calls sk_alloc proper, and when the
last reference to the sock is released the sk->destruct is called
(PROTO_destruct) does the PROTO_net_family_put. Ditto for the socket case,
where PROTO_create, before calling the ->create of the "sub" module does the
PROTO_net_family_get, and at release time its PROTO_release does the same thing
that sock_release does. Something like this may well need extra info to be kept
at the private area of the proto family in struct sock protinfo or private slab
cache.

That is, we have a higher layer for net families, with locking for the whole
family done like it is on the tree now and a lower layer at the specific
net family, both having the same behaviour at its layers.

This option seems to be easy to implement with the current bluetooth
infrastructure (i.e. it has a net_families equivalent, it does the switching at
bt_create time, etc).

2. use the sk->prot (struct proto) infrastructure in some way.

Comments?
 
> Anyway, here is another idea. How about this (untested, uncompiled, just rfc).

I didn't liked it, kind of layering violation that I'm trying to avoid.

- Arnaldo
