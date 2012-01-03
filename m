From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] x86: fix and improve cmpxchg_double{,_local}()
Date: Tue, 03 Jan 2012 16:00:30 +0100
Message-ID: <1325602830.2320.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F01F12A020000780006A19B@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com,
	Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F01F12A020000780006A19B@nat28.tlf.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 02 janvier 2012 =C3=A0 17:02 +0000, Jan Beulich a =C3=A9crit :
> Just like the per-CPU ones they had several problems/shortcomings:
>=20
> Only the first memory operand was mentioned in the asm() operands, an=
d
> the 2x64-bit version didn't have a memory clobber while the 2x32-bit
> one did. The former allowed the compiler to not recognize the need to
> re-load the data in case it had it cached in some register, while the
> latter was overly destructive.
>=20
> The types of the local copies of the old and new values were incorrec=
t
> (the types of the pointed-to variables should be used here, to make
> sure the respective old/new variable types are compatible).
>=20
> The __dummy/__junk variables were pointless, given that local copies
> of the inputs already existed (and can hence be used for discarded
> outputs).
>=20
> The 32-bit variant of cmpxchg_double_local() referenced
> cmpxchg16b_local().
>=20
> At once also
> - change the return value type to what it really is: 'bool'
> - unify 32- and 64-bit variants
> - abstract out the common part of the 'normal' and 'local' variants
>=20
> Signed-off-by: Jan Beulich <jbeulich@suse.com>

While looking at your patch, I discovered that atomic64_add() /
atomic64_inc() on 32bit are completely buggy. Oh well...

Generated code :

c03bc00c <atomic64_add_return_cx8>:
c03bc00c:       55                      push   %ebp
c03bc00d:       53                      push   %ebx
c03bc00e:       56                      push   %esi
c03bc00f:       57                      push   %edi
c03bc010:       89 c6                   mov    %eax,%esi
c03bc012:       89 d7                   mov    %edx,%edi
c03bc014:       89 cd                   mov    %ecx,%ebp
c03bc016:       89 d8                   mov    %ebx,%eax
c03bc018:       89 ca                   mov    %ecx,%edx
c03bc01a:       f0 0f c7 4d 00          lock cmpxchg8b 0x0(%ebp)
c03bc01f:       89 c3                   mov    %eax,%ebx
c03bc021:       89 d1                   mov    %edx,%ecx
c03bc023:       01 f3                   add    %esi,%ebx
c03bc025:       11 f9                   adc    %edi,%ecx
c03bc027:       f0 0f c7 4d 00          lock cmpxchg8b 0x0(%ebp)
c03bc02c:       75 f9                   jne    c03bc027 <atomic64_add_r=
eturn_cx8+0x1b>
c03bc02e:       89 d8                   mov    %ebx,%eax
c03bc030:       89 ca                   mov    %ecx,%edx
c03bc032:       5f                      pop    %edi
c03bc033:       5e                      pop    %esi
c03bc034:       5b                      pop    %ebx
c03bc035:       5d                      pop    %ebp
c03bc036:       c3                      ret

The ' jne c03bc027' should really be 'jne c03bc01f'

No idea how old is this bug.
