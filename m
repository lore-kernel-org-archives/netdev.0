From: Michal Ostrowski <mostrows@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
	"alive" pppoe interfaces
Date: Mon, 19 Oct 2009 08:19:23 -0500
Message-ID: <e6d1cecd0910190619t3e009e1by49cc8f7307eb7cdb@mail.gmail.com>
References: <200910190002.39937.denys@visp.net.lb>
	 <e6d1cecd0910182034t9d24859mc6f392875b36ad17@mail.gmail.com>
	 <4ADC5D3B.8010006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net,
	Cyrill Gorcunov <gorcunov@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <4ADC5D3B.8010006@gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The entire scheme for managing net namespaces seems unsafe.  We depend
on synchronization via pn->hash_lock, but have no guarantee of the
existence of the "net" object -- hence no way to ensure the existence
of the lock itself.  This should be relatively easy to fix though as
we should be able to get/put the net namespace as we add remove
objects to/from the pppoe hash.

Once you solve this existence issue, the flush_lock can be eliminated
altogether since all of the relevant code paths already depend on a
write_lock_bh(&pn->hash_lock), and that's the lock that should be use
to protect the pppoe_dev field.

Another patch to follow later...

--
Michal Ostrowski
mostrows@gmail.com



On Mon, Oct 19, 2009 at 7:36 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Michal Ostrowski a =E9crit :
>> Here's my theory on this after an inital look...
>>
>> Looking at the oops report and disassembly of the actual module bina=
ry
>> that caused the oops, one can deduce that:
>>
>> Execution was in pppoe_flush_dev(). =A0%ebx contained the pointer "s=
truct
>> pppox_sock *po", which is what we faulted on, excuting "cmp %eax, 0x=
190(%ebx)".
>> %ebx value was 0xffffffff (hence we got "NULL pointer dereference at=
 0x18f").
>>
>> At this point "i" (stored in %esi) is 15 (valid), meaning that we go=
t a value
>> of 0xffffffff in pn->hash_table[i].
>>
>>>From this I'd hypothesize that the combination of dev_put() and rele=
ase_sock()
>> may have allowed us to free "pn". =A0At the bottom of the loop we al=
reayd
>> recognize that since locks are dropped we're responsible for handlin=
g
>> invalidation of objects, and perhaps that should be extended to "pn"=
 as well.
>> --
>> Michal Ostrowski
>> mostrows@gmail.com
>>
>>
>
> Looking at this stuff, I do believe flush_lock protection is not
> properly done.
>
> At the end of pppoe_connect() for example we can find :
>
> err_put:
> =A0 =A0 =A0 =A0if (po->pppoe_dev) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_put(po->pppoe_dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0po->pppoe_dev =3D NULL;
> =A0 =A0 =A0 =A0}
>
> This is done without any protection, and can therefore clash with
> pppoe_flush_dev() :
>
> =A0 =A0 =A0 =A0spin_lock(&flush_lock);
> =A0 =A0 =A0 =A0po->pppoe_dev =3D NULL; /* ppoe_dev can already be NUL=
L before this point */
> =A0 =A0 =A0 =A0spin_unlock(&flush_lock);
>
> =A0 =A0 =A0 =A0dev_put(dev); =A0 =A0/* oops */
>
