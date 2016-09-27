From: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: implement more accurate skb tracking
Date: Tue, 27 Sep 2016 11:06:09 +0200
Message-ID: <c7b81eec-974a-a624-fbac-6d06f5380261@broadcom.com>
References: <20160926102348.8695-1-zajec5@gmail.com>
 <09084e8b-829d-9a13-ae16-a493438216ac@broadcom.com>
 <CACna6rwnLb3sEPmdx6uhYMstVn04WbP2xzznsjnwgguEXn04=w@mail.gmail.com>
 <1474901966.4519.8.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Pieter-Paul Giesberts <pieter-paul.giesberts-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Franky Lin <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1474901966.4519.8.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 26-9-2016 16:59, Dan Williams wrote:
> On Mon, 2016-09-26 at 14:13 +0200, Rafał Miłecki wrote:
>> On 26 September 2016 at 13:46, Arend Van Spriel
>> <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
>>>
>>> On 26-9-2016 12:23, Rafał Miłecki wrote:
>>>>
>>>> From: Rafał Miłecki <rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org>
>>>>
>>>> We need to track 802.1x packets to know if there are any pending
>>>> ones
>>>> for transmission. This is required for performing key update in
>>>> the
>>>> firmware.
>>>
>>> The problem we are trying to solve is a pretty old one. The problem
>>> is
>>> that wpa_supplicant uses two separate code paths: EAPOL messaging
>>> through data path and key configuration though nl80211.
>>
>> Can I find it described/reported somewhere?
> 
> If I understand the issue correctly, you can find all this in the
> supplicant code.  Once the supplicant has done whatever it wants to do
> with the data frames that just happen to be EAPOL it then sends the
> keys down to the driver with nl80211.

Indeed. EAPOL packets are simply data packets as far as the 802.11 stack
is concerned. The arrival of those in the driver is not predictable
hence we hold off the key configuration until those have been passed
over to firmware.

> But it sounds like, instead of sniffing EAPOL frames in the driver skb
> tracking and sniffing ETH_P_PAE, you should probably implement support
> for NL80211_CMD_CRIT_PROTOCOL_START/NL80211_CMD_CRIT_PROTOCOL_STOP and
> key off the passed-in NL80211_CRIT_PROTO_EAPOL.  At least at the
> beginning of connection setup only EAPOL packets will be allowed
> anyway.
> 
> It doesn't seem like the supplicant uses NL80211_CRIT_PROTO_EAPOL yet,
> but that should also be fixed in the supplicant itself.  You should
> probably get some comments from Jouni on how he'd like to see all this
> work.  But generally the less specific sniffing of frames in drivers,
> likely the better.

Indeed. That was the main motivation to introduce the CRIT_PROTO api. If
I recall correctly it was considered the task of the network manager to
issue the START/STOP. Recently noticed the use of CRIT_PROTO_DHCP on
some target system, which we already support in brcmfmac. From your
response I guess you consider CRIT_PROTO_EAPOL to be issued by the
supplicant.

Regards,
Arend

> Dan
> 
>>
>>>
>>>>
>>>> Unfortunately our old tracking code wasn't very accurate. It was
>>>> treating skb as pending as soon as it was passed by the netif.
>>>> Actual
>>>> handling packet to the firmware was happening later as brcmfmac
>>>> internally queues them and uses its own worker(s).
>>>
>>> That does not seem right. As soon as we get a 1x packet we need to
>>> wait
>>> with key configuration regardless whether it is still in the driver
>>> or
>>> handed over to firmware already.
>>
>> OK, thanks.
