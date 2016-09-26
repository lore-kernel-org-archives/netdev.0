From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] brcmfmac: implement more accurate skb tracking
Date: Mon, 26 Sep 2016 09:59:26 -0500
Message-ID: <1474901966.4519.8.camel@redhat.com>
References: <20160926102348.8695-1-zajec5@gmail.com>
         <09084e8b-829d-9a13-ae16-a493438216ac@broadcom.com>
         <CACna6rwnLb3sEPmdx6uhYMstVn04WbP2xzznsjnwgguEXn04=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        Franky Lin <frankyl@broadcom.com>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <brcm80211-dev-list.pdl@broadcom.com>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <rafal@milecki.pl>
To: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACna6rwnLb3sEPmdx6uhYMstVn04WbP2xzznsjnwgguEXn04=w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-09-26 at 14:13 +0200, Rafał Miłecki wrote:
> On 26 September 2016 at 13:46, Arend Van Spriel
> <arend.vanspriel@broadcom.com> wrote:
> > 
> > On 26-9-2016 12:23, Rafał Miłecki wrote:
> > > 
> > > From: Rafał Miłecki <rafal@milecki.pl>
> > > 
> > > We need to track 802.1x packets to know if there are any pending
> > > ones
> > > for transmission. This is required for performing key update in
> > > the
> > > firmware.
> > 
> > The problem we are trying to solve is a pretty old one. The problem
> > is
> > that wpa_supplicant uses two separate code paths: EAPOL messaging
> > through data path and key configuration though nl80211.
> 
> Can I find it described/reported somewhere?

If I understand the issue correctly, you can find all this in the
supplicant code.  Once the supplicant has done whatever it wants to do
with the data frames that just happen to be EAPOL it then sends the
keys down to the driver with nl80211.

But it sounds like, instead of sniffing EAPOL frames in the driver skb
tracking and sniffing ETH_P_PAE, you should probably implement support
for NL80211_CMD_CRIT_PROTOCOL_START/NL80211_CMD_CRIT_PROTOCOL_STOP and
key off the passed-in NL80211_CRIT_PROTO_EAPOL.  At least at the
beginning of connection setup only EAPOL packets will be allowed
anyway.

It doesn't seem like the supplicant uses NL80211_CRIT_PROTO_EAPOL yet,
but that should also be fixed in the supplicant itself.  You should
probably get some comments from Jouni on how he'd like to see all this
work.  But generally the less specific sniffing of frames in drivers,
likely the better.

Dan

> 
> > 
> > > 
> > > Unfortunately our old tracking code wasn't very accurate. It was
> > > treating skb as pending as soon as it was passed by the netif.
> > > Actual
> > > handling packet to the firmware was happening later as brcmfmac
> > > internally queues them and uses its own worker(s).
> > 
> > That does not seem right. As soon as we get a 1x packet we need to
> > wait
> > with key configuration regardless whether it is still in the driver
> > or
> > handed over to firmware already.
> 
> OK, thanks.
