From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] x86: fix and improve cmpxchg_double{,_local}()
Date: Tue, 03 Jan 2012 16:15:14 +0100
Message-ID: <1325603714.2320.73.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F01F12A020000780006A19B@nat28.tlf.novell.com>
	 <1325602830.2320.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com,
	Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:46757 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753418Ab2ACPPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 10:15:20 -0500
In-Reply-To: <1325602830.2320.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 03 janvier 2012 =C3=A0 16:00 +0100, Eric Dumazet a =C3=A9crit =
:

> While looking at your patch, I discovered that atomic64_add() /
> atomic64_inc() on 32bit are completely buggy. Oh well...
>=20
> Generated code :
>=20
> c03bc00c <atomic64_add_return_cx8>:
> c03bc00c:       55                      push   %ebp
> c03bc00d:       53                      push   %ebx
> c03bc00e:       56                      push   %esi
> c03bc00f:       57                      push   %edi
> c03bc010:       89 c6                   mov    %eax,%esi
> c03bc012:       89 d7                   mov    %edx,%edi
> c03bc014:       89 cd                   mov    %ecx,%ebp
> c03bc016:       89 d8                   mov    %ebx,%eax
> c03bc018:       89 ca                   mov    %ecx,%edx
> c03bc01a:       f0 0f c7 4d 00          lock cmpxchg8b 0x0(%ebp)
> c03bc01f:       89 c3                   mov    %eax,%ebx
> c03bc021:       89 d1                   mov    %edx,%ecx
> c03bc023:       01 f3                   add    %esi,%ebx
> c03bc025:       11 f9                   adc    %edi,%ecx
> c03bc027:       f0 0f c7 4d 00          lock cmpxchg8b 0x0(%ebp)
> c03bc02c:       75 f9                   jne    c03bc027 <atomic64_add=
_return_cx8+0x1b>
> c03bc02e:       89 d8                   mov    %ebx,%eax
> c03bc030:       89 ca                   mov    %ecx,%edx
> c03bc032:       5f                      pop    %edi
> c03bc033:       5e                      pop    %esi
> c03bc034:       5b                      pop    %ebx
> c03bc035:       5d                      pop    %ebp
> c03bc036:       c3                      ret
>=20
> The ' jne c03bc027' should really be 'jne c03bc01f'
>=20
> No idea how old is this bug.
>=20

Very old it seems...

arch/x86/lib/atomic64_cx8_32.S

all "jxx 1b" are wrong if a LOCK_PREFIX is included after the 1: label

1:
	inst1
	LOCK_PREFIX
	cmpxchg8b (%ebp)
	jne 1b  / jumps to beginning of LOCK_PREFIX, inst1 is not replayed
