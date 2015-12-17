From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: Re: [PATCH] decnet: fix possible NULL deref in dnet_select_source()
Date: Thu, 17 Dec 2015 22:07:01 +0100
Message-ID: <CAOMGZ=FN68Qnj9J3-gwoYbsdfJTdi6SA5Mbi_6x=0KfSNSvxaQ@mail.gmail.com>
References: <5341A3C1.9060101@oracle.com>
	<1396821554.12330.51.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140407.151854.411047851818388937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-decnet-user@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140407.151854.411047851818388937.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7 April 2014 at 21:18, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 06 Apr 2014 14:59:14 -0700
>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> dnet_select_source() should make sure dn_ptr is not NULL.
>>
>> While looking at this decnet code, I believe I found a device
>> reference leak, lets fix it as well.
>>
>> Reported-by: Sasha Levin <sasha.levin@oracle.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> ---
>> It seems this bug is very old, no recent change is involved.
>
> The callers work hard to ensure this.
>
> Analyzing all call sites:
>
> 1) __dn_fib_res_prefsrc() uses the FIB entry device pointer, we should not
>    be adding FIB entries pointing to devices which do not have their
>    decnet private initialized yet.
>
> 2) dn_route_output_slow()
>
>    The paths leading to the dnet_select_address() call(s) check if
>    dev_out->dn_ptr is not NULL, except when using loopback.
>
> In some other paths the device comes from neigh->dev, from which the
> 'neigh' was looked up in dn_neigh_table.  There should not be neighbour
> entries in this table pointing to devices which do not have their
> decnet private setup yet.
>
> And in the loopback case, it is the decnet stack's responsibility to
> make sure ->dn_ptr is setup properly, else it should fail the module
> load and stack initialization.
>
> I think there is some core fundamental issue here, and just adding
> a NULL check to dnet_select_source() is just papering around the issue.
>
> Please look closer at the stack trace, this code, and my analysis
> above to figure out what's really going on so we can fix this properly.
>

Hi,

(Reviving old thread: https://lkml.org/lkml/2014/4/6/101)

I've just run into the same bug and I can confirm it's still present
on a stock Ubuntu kernel and can be reliably triggered by a non-root
user given that the loopback device is in a "down" state.

So as far as I understand:

dev_out->dn_ptr is assigned a non-NULL value in dn_dev_up() ->
dn_dev_create() when the loopback device is brought up (and set to
NULL when it is brought down).

dn_route_output_slow() doesn't check for a NULL value in the "No
destination? Assume its local" (!fld.daddr) case -- it also doesn't
check in any other way if the device is up or down.

Another bit in dn_route_output_slow() uses dn_dev_get_default() in
another "Not there? Perhaps its a local address" case, which _does_
check ->dn_ptr (but it uses decnet_default_device, not
init_net.loopback_dev).

There are other users of init_net.loopback_dev which don't seem to
check its ->dn_ptr.

I'm a bit uncertain about the other callsites that check ->dn_ptr for
a NULL value -- unless they take RTNL, how are they safe against a
race with somebody else bringing the device down (see
dn_dev_down()/dn_dev_delete()) and freeing ->dn_ptr after they get
ahold of it?

I think we could add NULL checks to dn_route_output_slow(). In any
case we shouldn't allow the device to be used if it's down, right?

I also understood from Sasha that decnet is generally in a bit of a
sorry state -- should we just add 'depends on BROKEN' in the Kconfig
to prevent more problems down the line?


Vegard
