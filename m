From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 03/11] cirrus/mac89x0: print MAC via printk format specifier
Date: Tue, 28 Feb 2012 21:45:30 +0100
Message-ID: <CAMuHMdW0Oh7h8tv85ScgHB50vMaZSU7S3cPJRsChnRe2sNL_kA@mail.gmail.com>
References: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
	<1330091162-8141-4-git-send-email-danny.kukawka@bisect.de>
	<CAMuHMdXAwgtwbCV_=qJnrs=YPZksoEBkjnQB=JbR7fc+UyKdzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdXAwgtwbCV_=qJnrs=YPZksoEBkjnQB=JbR7fc+UyKdzw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 25, 2012 at 11:15, Geert Uytterhoeven <geert@linux-m68k.org=
> wrote:
> On Fri, Feb 24, 2012 at 14:45, Danny Kukawka <danny.kukawka@bisect.de=
> wrote:
>> Print MAC/dev_addr via printk extended format specifier %pM instead
>> of custom code.
>>
>> Use memcpy to set the address to dev->dev_addr in set_mac_address,
>> instead of mxing it up in a for loop with printing a debug msg.
>>
>> Check also if the given address is valid.
>
> Why do you sneak in this check in this patch?

And it doesn't compile:

http://kisskb.ellerman.id.au/kisskb/buildresult/5752157/

drivers/net/ethernet/cirrus/mac89x0.c: In function =E2=80=98set_mac_add=
ress=E2=80=99:
drivers/net/ethernet/cirrus/mac89x0.c:597: warning: dereferencing
=E2=80=98void *=E2=80=99 pointer
drivers/net/ethernet/cirrus/mac89x0.c:597: error: request for member
=E2=80=98sa_data=E2=80=99 in something not a structure or union
drivers/net/ethernet/cirrus/mac89x0.c:600: warning: dereferencing
=E2=80=98void *=E2=80=99 pointer
drivers/net/ethernet/cirrus/mac89x0.c:600: error: request for member
=E2=80=98sa_data=E2=80=99 in something not a structure or union
drivers/net/ethernet/cirrus/mac89x0.c:595: warning: unused variable =E2=
=80=98saddr=E2=80=99

No patch included as I don't think this should have been applied as-is.

>> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
>> ---
>> =C2=A0drivers/net/ethernet/cirrus/mac89x0.c | =C2=A0 12 ++++++++----
>> =C2=A01 files changed, 8 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/cirrus/mac89x0.c b/drivers/net/eth=
ernet/cirrus/mac89x0.c
>> index 83781f3..a7324ce 100644
>> --- a/drivers/net/ethernet/cirrus/mac89x0.c
>> +++ b/drivers/net/ethernet/cirrus/mac89x0.c
>> @@ -592,10 +592,14 @@ static void set_multicast_list(struct net_devi=
ce *dev)
>> =C2=A0static int set_mac_address(struct net_device *dev, void *addr)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
>> - =C2=A0 =C2=A0 =C2=A0 printk("%s: Setting MAC address to ", dev->na=
me);
>> - =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < 6; i++)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(" %2.2x", =
dev->dev_addr[i] =3D ((unsigned char *)addr)[i]);
>> - =C2=A0 =C2=A0 =C2=A0 printk(".\n");
>> + =C2=A0 =C2=A0 =C2=A0 struct sockaddr *saddr =3D addr;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 if (!is_valid_ether_addr(addr->sa_data))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EADDRNOTA=
VAIL;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN=
);
>> + =C2=A0 =C2=A0 =C2=A0 printk("%s: Setting MAC address to %pM\n", de=
v->name, dev->dev_addr);
>> +
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* set the Ethernet address */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i=3D0; i < ETH_ALEN/2; i++)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0writereg(dev,=
 PP_IA+i*2, dev->dev_addr[i*2] | (dev->dev_addr[i*2+1] << 8));

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
