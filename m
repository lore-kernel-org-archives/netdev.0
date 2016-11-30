From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v4 0/4] Fix OdroidC2 Gigabit Tx link issue
Date: Wed, 30 Nov 2016 10:28:55 -0800
Message-ID: <6bcad1c0-2c98-9f91-3437-a5d889677860@gmail.com>
References: <1480348229-25672-1-git-send-email-jbrunet@baylibre.com>
 <049b1efc-3bad-92e0-45ef-0563dc5d81de@gmail.com>
 <1480499246.17538.208.camel@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Carlo Caione <carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org>,
        Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Andre Roth <neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>,
        Yegor Yefremov <yegorslists-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>
To: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1480499246.17538.208.camel-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/30/2016 01:47 AM, Jerome Brunet wrote:
>> If we start supporting generic "enable", "disable" type of properties
>> with values that map directly to register definitions of the HW, we
>> leave too much room for these properties to be utilized to implement
>> a
>> specific policy, and this is not acceptable.
> 
> Florian, 
> 
> I agree that DT should not be used to setup a policy, but to describe
> what the HW is.
> 
> I tried to implement it the way you suggested, using phy fixup, too see
> what it looks like.
> There is 2 places in the code that seems (remotely) linked to the
> issue: 
> - meson8b_dwmac driver : if the mac, regardless of the board/platform,
>  could not tolerate to have EEE activated, it would make sense to have
> the fixup here. It can provide a C callback for such case.
> - realtek phy driver: philosophy is kind of the same
> 
> To be clear, it is doable and it works that way, but I don't think
> embedding this directly in the code is the right way to do it. It seems
> we are hiding an information specific about the board inside a generic
> driver.

So there are a few things about that:

- if we were not on ARM64, there would be possibly a remote chance of
having some concept of a board file which would be where such a PHY
fixup, or fixup of any kind would reside

- having the PHY fixup in the PHY driver gated by both an exact match on
the PHY OUI *and* the specific affected board makes it reasonably easy
to locate it

> 
> We have several amlogic's design with the same MAC, sometimes with the
> same PHY, which have no problem with EEE at all. The issue is really
> about the board design.

OK, not a problem then: of_machine_is_compatible() should help you here?

> 
> What I propose is not an enable/disable configuration switch, but to
> clearly state that a particular mode of operation is broken. Like the
> "max-speed" property, it setup a restriction. IMO, this is a
> description of what the HW is and is capable of, and as such it should
> be part of the DT.

Sure, there is a fine line between describing what's broken, and being
able to use that to actually configure non-broken hardware the way you want.

> 
> Yes the property directly map to a register, but it does let you
> directly manipulate it (you can't pass the value you want to write in
> the register). Having it this way just makes the code simple on both
> ends (user and driver).

That's exactly the part that is giving me the creeps, any property that
directly maps to a register value has a chance of a) leading to hard to
debug problem if mis-configured, and b) being used as a policy as
opposed to purely describing what is going on with the HW.

> 
> Yes people could start abusing this to setup policy. In the end, it is
> our responsibility, as community, to make sure APIs are used in a
> proper way, and not let it be used that way.
> 
> I'm open to suggestion on how improve the solution, maybe something
> which could bring more confidence that property won't be misused.

Once the binding lands in the kernel, there is absolutely zero guarantee
nor visibility in how people end-up using in e.g: DT aware bootloader,
and I am one of these people. Since there is a binding, there is
consumer code in the kernel that needs to behave properly with respect
to how the binding is defined. This is the same problem as with any kind
of ABI, and a diverse range of consumers.
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
