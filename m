From: Marc Dionne <marc.c.dionne@gmail.com>
Subject: Re: Multi-thread udp 4.7 regression, bisected to 71d8c47fc653
Date: Mon, 27 Jun 2016 14:21:15 -0300
Message-ID: <CAB9dFdvQ4UyKNMmOSx+FePyR0_Q425XLJRb_k5h+4JOSkQkf3w@mail.gmail.com>
References: <CAB9dFduvE0dKzZ8Dm5RVVrUAq1Auvj8t9xXAyARGyO4NmowvYw@mail.gmail.com>
 <20160627142238.GA10613@breakpoint.cc> <CAB9dFds=qY=Dk++p7qVX7a8aOOH4wn0rtL3m4poO6HMQPuPrnA@mail.gmail.com>
 <20160627153820.GB10613@breakpoint.cc>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11447c0c75d6b5053645bfbd
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:32784 "EHLO
	mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbcF0RVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 13:21:17 -0400
Received: by mail-vk0-f54.google.com with SMTP id j3so28241440vkb.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 10:21:17 -0700 (PDT)
In-Reply-To: <20160627153820.GB10613@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a11447c0c75d6b5053645bfbd
Content-Type: text/plain; charset=UTF-8

On Mon, Jun 27, 2016 at 12:38 PM, Florian Westphal <fw@strlen.de> wrote:
> Marc Dionne <marc.c.dionne@gmail.com> wrote:
>> On Mon, Jun 27, 2016 at 11:22 AM, Florian Westphal <fw@strlen.de> wrote:
>> > Marc Dionne <marc.c.dionne@gmail.com> wrote:
>> >> Hi,
>
>> >         hlist_nulls_for_each_entry(h, n, &nf_conntrack_hash[hash], hnnode)
>> >                 if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
>> > -                                   zone, net))
>> > -                       goto out;
>> > +                                   zone, net)) {
>> > +                       nf_ct_add_to_dying_list(ct);
>> > +                       ret = nf_ct_resolve_clash(net, skb, ctinfo, h);
>> > +                       goto dying;
>> > +               }
>
> This is bogus as h can be a reply too (key compare does not deal
> with it).
>
> Below is what I actually intended; I can't come up with a reason why
> you experience this issue other than that we're getting confused over
> reply/original direction.
>
> If the patch doesn't help either, can you tell us what kind of iptables
> rules are installed on the affected system or perhaps report perf drop
> monitor stat when things go wrong?
>
> Thanks!

The additional patch didn't help either.

I had a lot of iptables bloat, but I reverted to old simple iptables
and ip6tables configs (attached), and still see the problem.  Note
that the test normally uses ipv6, but the behaviour is the same with
ipv4.

Marc

--001a11447c0c75d6b5053645bfbd
Content-Type: application/octet-stream; name=iptables
Content-Disposition: attachment; filename=iptables
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ipy9tp4i0

IyBzYW1wbGUgY29uZmlndXJhdGlvbiBmb3IgaXB0YWJsZXMgc2VydmljZQojIHlvdSBjYW4gZWRp
dCB0aGlzIG1hbnVhbGx5IG9yIHVzZSBzeXN0ZW0tY29uZmlnLWZpcmV3YWxsCiMgcGxlYXNlIGRv
IG5vdCBhc2sgdXMgdG8gYWRkIGFkZGl0aW9uYWwgcG9ydHMvc2VydmljZXMgdG8gdGhpcyBkZWZh
dWx0IGNvbmZpZ3VyYXRpb24KKmZpbHRlcgo6SU5QVVQgQUNDRVBUIFswOjBdCjpGT1JXQVJEIEFD
Q0VQVCBbMDowXQo6T1VUUFVUIEFDQ0VQVCBbMDowXQotQSBJTlBVVCAtbSBzdGF0ZSAtLXN0YXRl
IFJFTEFURUQsRVNUQUJMSVNIRUQgLWogQUNDRVBUCi1BIElOUFVUIC1wIGljbXAgLWogQUNDRVBU
Ci1BIElOUFVUIC1pIGxvIC1qIEFDQ0VQVAotQSBJTlBVVCAtcCB0Y3AgLW0gc3RhdGUgLS1zdGF0
ZSBORVcgLW0gdGNwIC0tZHBvcnQgMjIgLWogQUNDRVBUCi1BIElOUFVUIC1qIFJFSkVDVCAtLXJl
amVjdC13aXRoIGljbXAtaG9zdC1wcm9oaWJpdGVkCi1BIEZPUldBUkQgLWogUkVKRUNUIC0tcmVq
ZWN0LXdpdGggaWNtcC1ob3N0LXByb2hpYml0ZWQKQ09NTUlUCg==
--001a11447c0c75d6b5053645bfbd
Content-Type: application/octet-stream; name=ip6tables
Content-Disposition: attachment; filename=ip6tables
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ipy9tp591

IyBGaXJld2FsbCBjb25maWd1cmF0aW9uIHdyaXR0ZW4gYnkgc3lzdGVtLWNvbmZpZy1maXJld2Fs
bAojIE1hbnVhbCBjdXN0b21pemF0aW9uIG9mIHRoaXMgZmlsZSBpcyBub3QgcmVjb21tZW5kZWQu
CipmaWx0ZXIKOklOUFVUIEFDQ0VQVCBbMDowXQo6Rk9SV0FSRCBBQ0NFUFQgWzA6MF0KOk9VVFBV
VCBBQ0NFUFQgWzA6MF0KLUEgSU5QVVQgLW0gc3RhdGUgLS1zdGF0ZSBFU1RBQkxJU0hFRCxSRUxB
VEVEIC1qIEFDQ0VQVAotQSBJTlBVVCAtcCBpcHY2LWljbXAgLWogQUNDRVBUCi1BIElOUFVUIC1p
IGxvIC1qIEFDQ0VQVAotQSBJTlBVVCAtbSBzdGF0ZSAtLXN0YXRlIE5FVyAtbSB1ZHAgLXAgdWRw
IC0tZHBvcnQgNTQ2IC1kIGZlODA6Oi82NCAtaiBBQ0NFUFQKLUEgSU5QVVQgLW0gc3RhdGUgLS1z
dGF0ZSBORVcgLW0gdGNwIC1wIHRjcCAtLWRwb3J0IDIyIC1qIEFDQ0VQVAotQSBJTlBVVCAtbSBz
dGF0ZSAtLXN0YXRlIE5FVyAtbSB1ZHAgLXAgdWRwIC0tZHBvcnQgNjMxIC1qIEFDQ0VQVAotQSBJ
TlBVVCAtbSBzdGF0ZSAtLXN0YXRlIE5FVyAtbSB1ZHAgLXAgdWRwIC0tZHBvcnQgNTM1MyAtZCBm
ZjAyOjpmYiAtaiBBQ0NFUFQKLUEgSU5QVVQgLW0gc3RhdGUgLS1zdGF0ZSBORVcgLW0gdGNwIC1w
IHRjcCAtLWRwb3J0IDYzMSAtaiBBQ0NFUFQKLUEgSU5QVVQgLW0gc3RhdGUgLS1zdGF0ZSBORVcg
LW0gdWRwIC1wIHVkcCAtLWRwb3J0IDYzMSAtaiBBQ0NFUFQKLUEgSU5QVVQgLW0gc3RhdGUgLS1z
dGF0ZSBORVcgLW0gdWRwIC1wIHVkcCAtLWRwb3J0IDEzNyAtaiBBQ0NFUFQKLUEgSU5QVVQgLW0g
c3RhdGUgLS1zdGF0ZSBORVcgLW0gdWRwIC1wIHVkcCAtLWRwb3J0IDEzOCAtaiBBQ0NFUFQKLUEg
SU5QVVQgLWogUkVKRUNUIC0tcmVqZWN0LXdpdGggaWNtcDYtYWRtLXByb2hpYml0ZWQKLUEgRk9S
V0FSRCAtaiBSRUpFQ1QgLS1yZWplY3Qtd2l0aCBpY21wNi1hZG0tcHJvaGliaXRlZApDT01NSVQK
--001a11447c0c75d6b5053645bfbd--
