From: "George Spelvin" <linux@horizon.com>
Subject: RE: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: 10 Feb 2016 09:43:34 -0500
Message-ID: <20160210144334.23242.qmail@ns.horizon.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1CCDCC8D@AcuExch.aculab.com>
Cc: mingo@kernel.org
To: David.Laight@ACULAB.COM, linux-kernel@vger.kernel.org,
	linux@horizon.com, netdev@vger.kernel.org, tom@herbertland.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCDCC8D@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Laight wrote:
> Separate renaming allows:
> 1) The value to tested without waiting for pending updates to complete.
>    Useful for IE and DIR.

I don't quite follow.  It allows the value to be tested without waiting
for pending updates *of other bits* to complete.

Obviusly, the update of the bit being tested has to complete!

> I can't see any obvious gain from separating out O or Z (even with
> adcx and adox). You'd need some other instructions that don't set O (or Z)
> but set some other useful flags.
> (A decrement that only set Z for instance.)

I tried to describe the advantages in the previous message.

The problems arise much less often than the INC/DEC pair, but there are
instructions whick write only the O and C flags, (ROL, ROR) and only
the Z flag (CMPXCHG).

The sign, aux carry, and parity flags are *always* updated as
a group, so they can be renamed as a group.

> While LOOP could be used on Bulldozer+ an equivalently fast loop
> can be done with inc/dec and jnz.
> So you only care about LOOP/JCXZ when ADOX is supported.
> 
> I think the fastest loop is:
> 10:	adc	%rax,0(%rdi,%rcx,8)
> 	inc	%rcx
> 	jnz	10b
> but check if any cpu add an extra clock for the 'scaled' offset
> (they might be faster if %rdi is incremented).
> That loop looks like it will have no overhead on recent cpu.

Well, it should execute at 1 instruction/cycle.  (No, a scaled offset
doesn't take extra time.)  To break that requires ADCX/ADOX:

10:	adcxq	0(%rdi,%rcx),%rax
	adoxq	8(%rdi,%rcx),%rdx
 	leaq	16(%rcx),%rcx
	jrcxz	11f
 	j	10b
11:
