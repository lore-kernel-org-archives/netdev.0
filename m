From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH] csum: Update csum_block_add to use rotate
 instead of byteswap
Date: Wed, 09 Mar 2016 16:18:33 -0800
Message-ID: <1457569113.3433.7.camel@perches.com>
References: <20160308224238.16551.73881.stgit@localhost.localdomain>
	 <1457479557.4067.9.camel@perches.com>
	 <CAKgT0Uc94UgzzcNXeFDvA4NKJN78hi-n7d2ar9YFiR8yGhW8Gw@mail.gmail.com>
	 <1457502647.4067.38.camel@perches.com>
	 <CAKgT0Ud=X55Y9Cj-kO=px0DKSXYwYbza+UsVbNOJGVxHLaYM0w@mail.gmail.com>
	 <CALx6S34WoWcK05J52q2z242Nyk7N1q9YjJDw7HsZ4s3VKWoonA@mail.gmail.com>
	 <CAKgT0UebO62GBsmL17JrZW0Ptzmr05buc1x6pHv6A_PAr4HBLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0140.hostedemail.com ([216.40.44.140]:59375 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933532AbcCJASi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 19:18:38 -0500
In-Reply-To: <CAKgT0UebO62GBsmL17JrZW0Ptzmr05buc1x6pHv6A_PAr4HBLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-03-09 at 08:08 -0800, Alexander Duyck wrote:
> On Tue, Mar 8, 2016 at 10:31 PM, Tom Herbert <tom@herbertland.com> wr=
ote:
> > I took a look inlining these.
> >=20
> > #define rol32(V, X) ({=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0\
> > =A0=A0=A0=A0=A0=A0=A0=A0int word =3D V;=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0\
> > =A0=A0=A0=A0=A0=A0=A0=A0if (__builtin_constant_p(X))=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0\
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0asm("roll $" #X ",%=
[word]\n\t"=A0=A0\
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0: [word=
] "=3Dr" (word));=A0=A0=A0=A0=A0=A0\
> > =A0=A0=A0=A0=A0=A0=A0=A0else=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0\
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0asm("roll %%cl,%[wo=
rd]\n\t"=A0=A0=A0=A0=A0\
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0: [word=
] "=3Dr" (word)=A0=A0=A0=A0=A0=A0=A0=A0\
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0: "c" (=
X));=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0\
> > =A0=A0=A0=A0=A0=A0=A0=A0word;=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0\
> > })
> >=20
> > With this I'm seeing a nice speedup in jhash which uses a lot of ro=
l32s...
> Is gcc really not converting the rol32 calls into rotates?

No, it is.

The difference in the object code with the asm for instance is:

(old, compiled with gcc 5.3.1)

<jhash_2words.constprop.5>:
=A0=A0=A0=A0=A084e:=A0=A0=A0=A0=A0=A0=A081 ee 09 41 52 21=A0=A0=A0=A0=A0=
=A0=A0sub=A0=A0=A0=A0$0x21524109,%esi
=A0=A0=A0=A0=A0854:=A0=A0=A0=A0=A0=A0=A081 ef 09 41 52 21=A0=A0=A0=A0=A0=
=A0=A0sub=A0=A0=A0=A0$0x21524109,%edi
=A0=A0=A0=A0=A085a:=A0=A0=A0=A0=A0=A0=A055=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0push=A0=A0=A0%rbp
=A0=A0=A0=A0=A085b:=A0=A0=A0=A0=A0=A0=A089 f0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mov=A0=A0=A0=A0%esi,%eax
=A0=A0=A0=A0=A085d:=A0=A0=A0=A0=A0=A0=A089 f2=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mov=A0=A0=A0=A0%esi,%edx
=A0=A0=A0=A0=A085f:=A0=A0=A0=A0=A0=A0=A048 ff 05 00 00 00 00=A0=A0=A0=A0=
incq=A0=A0=A00x0(%rip)=A0=A0=A0=A0=A0=A0=A0=A0# 866 <jhash_2words.const=
prop.5+0x18>
=A0=A0=A0=A0=A0866:=A0=A0=A0=A0=A0=A0=A0c1 c2 0e=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0rol=A0=A0=A0=A0$0xe,%edx
=A0=A0=A0=A0=A0869:=A0=A0=A0=A0=A0=A0=A035 f7 be ad de=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0xor=A0=A0=A0=A0$0xdeadbef7,%eax
=A0=A0=A0=A0=A086e:=A0=A0=A0=A0=A0=A0=A048 89 e5=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0mov=A0=A0=A0=A0%rsp,%rbp
=A0=A0=A0=A0=A0871:=A0=A0=A0=A0=A0=A0=A029 d0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sub=A0=A0=A0=A0%edx,%eax
=A0=A0=A0=A0=A0873:=A0=A0=A0=A0=A0=A0=A048 ff 05 00 00 00 00=A0=A0=A0=A0=
incq=A0=A0=A00x0(%rip)=A0=A0=A0=A0=A0=A0=A0=A0# 87a <jhash_2words.const=
prop.5+0x2c>
=A0=A0=A0=A0=A087a:=A0=A0=A0=A0=A0=A0=A048 ff 05 00 00 00 00=A0=A0=A0=A0=
incq=A0=A0=A00x0(%rip)=A0=A0=A0=A0=A0=A0=A0=A0# 881 <jhash_2words.const=
prop.5+0x33>
=A0=A0=A0=A0=A0881:=A0=A0=A0=A0=A0=A0=A089 c2=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mov=A0=A0=A0=A0%eax,%edx
=A0=A0=A0=A0=A0883:=A0=A0=A0=A0=A0=A0=A031 c7=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0xor=A0=A0=A0=A0%eax,%edi
=A0=A0=A0=A0=A0885:=A0=A0=A0=A0=A0=A0=A0c1 c2 0b=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0rol=A0=A0=A0=A0$0xb,%edx
=A0=A0=A0=A0=A0888:=A0=A0=A0=A0=A0=A0=A029 d7=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sub=A0=A0=A0=A0%edx,%edi
=A0=A0=A0=A0=A088a:=A0=A0=A0=A0=A0=A0=A089 fa=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mov=A0=A0=A0=A0%edi,%edx
=A0=A0=A0=A0=A088c:=A0=A0=A0=A0=A0=A0=A031 fe=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0xor=A0=A0=A0=A0%edi,%esi
=A0=A0=A0=A0=A088e:=A0=A0=A0=A0=A0=A0=A0c1 ca 07=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0ror=A0=A0=A0=A0$0x7,%edx
=A0=A0=A0=A0=A0891:=A0=A0=A0=A0=A0=A0=A029 d6=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sub=A0=A0=A0=A0%edx,%esi
=A0=A0=A0=A0=A0893:=A0=A0=A0=A0=A0=A0=A089 f2=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mov=A0=A0=A0=A0%esi,%edx
=A0=A0=A0=A0=A0895:=A0=A0=A0=A0=A0=A0=A031 f0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0xor=A0=A0=A0=A0%esi,%eax
=A0=A0=A0=A0=A0897:=A0=A0=A0=A0=A0=A0=A0c1 c2 10=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0rol=A0=A0=A0=A0$0x10,%edx
=A0=A0=A0=A0=A089a:=A0=A0=A0=A0=A0=A0=A029 d0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sub=A0=A0=A0=A0%edx,%eax
=A0=A0=A0=A0=A089c:=A0=A0=A0=A0=A0=A0=A089 c2=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mov=A0=A0=A0=A0%eax,%edx
=A0=A0=A0=A0=A089e:=A0=A0=A0=A0=A0=A0=A031 c7=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0xor=A0=A0=A0=A0%eax,%edi
=A0=A0=A0=A0=A08a0:=A0=A0=A0=A0=A0=A0=A0c1 c2 04=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0rol=A0=A0=A0=A0$0x4,%edx
=A0=A0=A0=A0=A08a3:=A0=A0=A0=A0=A0=A0=A029 d7=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sub=A0=A0=A0=A0%edx,%edi
=A0=A0=A0=A0=A08a5:=A0=A0=A0=A0=A0=A0=A031 fe=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0xor=A0=A0=A0=A0%edi,%esi
=A0=A0=A0=A0=A08a7:=A0=A0=A0=A0=A0=A0=A0c1 c7 0e=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0rol=A0=A0=A0=A0$0xe,%edi
=A0=A0=A0=A0=A08aa:=A0=A0=A0=A0=A0=A0=A029 fe=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sub=A0=A0=A0=A0%edi,%esi
=A0=A0=A0=A0=A08ac:=A0=A0=A0=A0=A0=A0=A031 f0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0xor=A0=A0=A0=A0%esi,%eax
=A0=A0=A0=A0=A08ae:=A0=A0=A0=A0=A0=A0=A0c1 ce 08=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0ror=A0=A0=A0=A0$0x8,%esi
=A0=A0=A0=A0=A08b1:=A0=A0=A0=A0=A0=A0=A029 f0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sub=A0=A0=A0=A0%esi,%eax
=A0=A0=A0=A0=A08b3:=A0=A0=A0=A0=A0=A0=A05d=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pop=A0=A0=A0=A0%rbp
=A0=A0=A0=A0=A08b4:=A0=A0=A0=A0=A0=A0=A0c3=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0retq=A0=A0=A0

vs Tom's asm

000000000000084e <jhash_2words.constprop.5>:
=A0=A0=A0=A0=A084e:=A0=A0=A0=A0=A0=A0=A081 ee 09 41 52 21=A0=A0=A0=A0=A0=
=A0=A0sub=A0=A0=A0=A0$0x21524109,%esi
=A0=A0=A0=A0=A0854:=A0=A0=A0=A0=A0=A0=A08d 87 f7 be ad de=A0=A0=A0=A0=A0=
=A0=A0lea=A0=A0=A0=A0-0x21524109(%rdi),%eax
=A0=A0=A0=A0=A085a:=A0=A0=A0=A0=A0=A0=A055=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0push=A0=A0=A0%rbp
=A0=A0=A0=A0=A085b:=A0=A0=A0=A0=A0=A0=A089 f2=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mov=A0=A0=A0=A0%esi,%edx
=A0=A0=A0=A0=A085d:=A0=A0=A0=A0=A0=A0=A048 ff 05 00 00 00 00=A0=A0=A0=A0=
incq=A0=A0=A00x0(%rip)=A0=A0=A0=A0=A0=A0=A0=A0# 864 <jhash_2words.const=
prop.5+0x16>
=A0=A0=A0=A0=A0864:=A0=A0=A0=A0=A0=A0=A048 ff 05 00 00 00 00=A0=A0=A0=A0=
incq=A0=A0=A00x0(%rip)=A0=A0=A0=A0=A0=A0=A0=A0# 86b <jhash_2words.const=
prop.5+0x1d>
=A0=A0=A0=A0=A086b:=A0=A0=A0=A0=A0=A0=A081 f2 f7 be ad de=A0=A0=A0=A0=A0=
=A0=A0xor=A0=A0=A0=A0$0xdeadbef7,%edx
=A0=A0=A0=A0=A0871:=A0=A0=A0=A0=A0=A0=A048 89 e5=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0mov=A0=A0=A0=A0%rsp,%rbp
=A0=A0=A0=A0=A0874:=A0=A0=A0=A0=A0=A0=A0c1 c1 0e=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0rol=A0=A0=A0=A0$0xe,%ecx
=A0=A0=A0=A0=A0877:=A0=A0=A0=A0=A0=A0=A029 ca=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sub=A0=A0=A0=A0%ecx,%edx
=A0=A0=A0=A0=A0879:=A0=A0=A0=A0=A0=A0=A031 d0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0xor=A0=A0=A0=A0%edx,%eax
=A0=A0=A0=A0=A087b:=A0=A0=A0=A0=A0=A0=A0c1 c7 0b=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0rol=A0=A0=A0=A0$0xb,%edi
=A0=A0=A0=A0=A087e:=A0=A0=A0=A0=A0=A0=A029 f8=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sub=A0=A0=A0=A0%edi,%eax
=A0=A0=A0=A0=A0880:=A0=A0=A0=A0=A0=A0=A048 ff 05 00 00 00 00=A0=A0=A0=A0=
incq=A0=A0=A00x0(%rip)=A0=A0=A0=A0=A0=A0=A0=A0# 887 <jhash_2words.const=
prop.5+0x39>
=A0=A0=A0=A0=A0887:=A0=A0=A0=A0=A0=A0=A031 c6=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0xor=A0=A0=A0=A0%eax,%esi
=A0=A0=A0=A0=A0889:=A0=A0=A0=A0=A0=A0=A0c1 c7 19=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0rol=A0=A0=A0=A0$0x19,%edi
=A0=A0=A0=A0=A088c:=A0=A0=A0=A0=A0=A0=A029 fe=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sub=A0=A0=A0=A0%edi,%esi
=A0=A0=A0=A0=A088e:=A0=A0=A0=A0=A0=A0=A031 f2=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0xor=A0=A0=A0=A0%esi,%edx
=A0=A0=A0=A0=A0890:=A0=A0=A0=A0=A0=A0=A0c1 c7 10=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0rol=A0=A0=A0=A0$0x10,%edi
=A0=A0=A0=A0=A0893:=A0=A0=A0=A0=A0=A0=A029 fa=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sub=A0=A0=A0=A0%edi,%edx
=A0=A0=A0=A0=A0895:=A0=A0=A0=A0=A0=A0=A031 d0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0xor=A0=A0=A0=A0%edx,%eax
=A0=A0=A0=A0=A0897:=A0=A0=A0=A0=A0=A0=A0c1 c7 04=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0rol=A0=A0=A0=A0$0x4,%edi
=A0=A0=A0=A0=A089a:=A0=A0=A0=A0=A0=A0=A029 f8=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sub=A0=A0=A0=A0%edi,%eax
=A0=A0=A0=A0=A089c:=A0=A0=A0=A0=A0=A0=A031 f0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0xor=A0=A0=A0=A0%esi,%eax
=A0=A0=A0=A0=A089e:=A0=A0=A0=A0=A0=A0=A029 c8=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sub=A0=A0=A0=A0%ecx,%eax
=A0=A0=A0=A0=A08a0:=A0=A0=A0=A0=A0=A0=A031 d0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0xor=A0=A0=A0=A0%edx,%eax
=A0=A0=A0=A0=A08a2:=A0=A0=A0=A0=A0=A0=A05d=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pop=A0=A0=A0=A0%rbp
=A0=A0=A0=A0=A08a3:=A0=A0=A0=A0=A0=A0=A0c1 c2 18=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0rol=A0=A0=A0=A0$0x18,%edx
=A0=A0=A0=A0=A08a6:=A0=A0=A0=A0=A0=A0=A029 d0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sub=A0=A0=A0=A0%edx,%eax
=A0=A0=A0=A0=A08a8:=A0=A0=A0=A0=A0=A0=A0c3=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0retq=A0=A0=A0

> If we need this type of code in order to get the rotates to occur as
> expected then maybe we need to look at doing arch specific versions o=
f
> the functions in bitops.h in order to improve the performance since I
> know these calls are used in some performance critical paths such as
> crypto and hashing.

Yeah, maybe, but why couldn't gcc generate similar code
as Tom's asm? (modulo the ripple reducing ror vs rol uses
when the shift is > 16
