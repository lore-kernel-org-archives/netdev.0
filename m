From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: Re: [PATCH 04/10] net: stmmac: sunxi platfrom
 extensions for GMAC in Allwinner A20 SoC's
Date: Tue, 24 Dec 2013 11:27:45 +0800
Message-ID: <CAGb2v64Q1PSMw_nULBHMR5eOC44hWBPewchxE_4sO+4XN8_sDA@mail.gmail.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-5-git-send-email-wens@csie.org> <52A5A52C.50605@st.com>
 <CAGb2v67WiCaMpJEzA_X6o7uOu6i3w3FCEz7=N5HY0amQb01SZA@mail.gmail.com>
 <52A72C6D.60100@st.com> <CAGb2v64qQvqJSicA6MTAxeh1sGjWY=Pk=vDq=9J3pTQW+wkXrA@mail.gmail.com>
 <52A87A74.8040807@st.com> <20131212090415.GQ3651@lukather>
 <CAGb2v655_83b76PTmgkDmNGCADWwTjTwW13sOgM5HFmCVkeu=w@mail.gmail.com> <20131213103822.GX3651@lukather>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Srinivas KANDAGATLA <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>, Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBR764OKQKGQEOW7RDKY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20131213103822.GX3651@lukather>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi,

On Fri, Dec 13, 2013 at 6:38 PM, Maxime Ripard
<maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> wrote:
> On Thu, Dec 12, 2013 at 06:31:43PM +0800, Chen-Yu Tsai wrote:
>> Hi,
>>
>> On Thu, Dec 12, 2013 at 5:04 PM, Maxime Ripard
>> <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> wrote:
>> > Hi,
>> >
>> > On Wed, Dec 11, 2013 at 02:45:08PM +0000, srinivas kandagatla wrote:
>> >> >>> 1. .tx_coe
>> >> >>>    This is not exported in the DT bindings.
>> >> >>>    Looking at stmmac code, not setting this seems to disable all
>> >> >>>    checksum offloading.
>> >> >>
>> >> >> Why cant this go via DT as well?
>> >> >
>> >> > If you and Giuseppe are OK with this, why not?
>> >> Am Ok with it.
>> >
>> > Please note that I'm opposed to this until someone explain why putting
>> > it in the DT is relevant (and not just convenient).
>>
>> Checksum offloading is an optional feature[1], implemented starting
>> from version 3.20a. It is not tied to a specific IP version. As such,
>> using a "snps,dwmac-<version>" compatible isn't a good fit here.
>
> No, but we're not in such case. Since we have a compatible of our own,
> we can derive it from that. Putting a property in the DT would only be
> redundant.
>
>> stmmac does auto-detection for optional features on MAC version > 3.50a.
>> This is what Srinivas was referring to.
>>
>> Unfortunately, our MAC is < 3.50a. No auto-detection. We could add a
>> "snps,dwmac-tx-coe" compatible for this, or the seperate DT property.
>>
>> The other way would be to pass the flags in the initial .data with the
>> SoC specific compatible. Other SoCs with the same feature won't be
>> able to reuse the same compatible though.
>
> Which is already pretty much the case, since we have to deal with
> Allwinner specific code and features.
>
> A new compatible is cheap to maintain, a new property is not.

Srinivas,

Let's keep platform data as of_data, so SoC compatibles can pass
hardware feature flags for cores that don't support auto-detection.

We can adjust the callbacks as you suggested, and I added a .free
to complement .setup. Driver private data and platform data are
off limits to the callbacks. My version of the callbacks:

        void (*fix_mac_speed)(void *priv, unsigned int speed);
        void (*bus_setup)(void __iomem *ioaddr);
        void *(*setup)(struct platform_device *pdev);
        void (*free)(struct platform_device *pdev, void *priv);
        int (*init)(struct platform_device *pdev, void *priv);
        void (*exit)(struct platform_device *pdev, void *priv);


Cheers,

ChenYu
