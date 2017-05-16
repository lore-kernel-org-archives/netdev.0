From: Jes Sorensen <jes.sorensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] rt2x00: improve calling conventions for register
 accessors
Date: Tue, 16 May 2017 10:31:00 -0400
Message-ID: <0080a870-2d15-9b60-b7fb-8847d3c8aa8a@gmail.com>
References: <20170515134711.2770374-1-arnd@arndb.de>
 <20170515142520.GA13996@redhat.com>
 <20170515.103951.2305484593464882104.davem@davemloft.net>
 <20170516115511.GA4230@redhat.com>
 <0ce21c48-1d2c-3035-3c6e-52c7debf86d5@gmail.com>
 <CAK8P3a18opkvCyoNmYhR6M7XXEq8f__hMZH1A6w8UFP7qbmQWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Daniel Golle <daniel-g5gK2j5usbvCyp4qypjU+w@public.gmane.org>,
        Mathias Kresin <dev-zg6vgJgm1sizQB+pC5nmwQ@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        =?UTF-8?Q?Tomislav_Po=c5=beega?= <pozega.tomislav-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Serge Vasilugin <vasilugin-o+MxOtu4lMCHXe+LvDLADg@public.gmane.org>,
        Roman Yeryomin <roman-9zmcapQ0v8Q@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAK8P3a18opkvCyoNmYhR6M7XXEq8f__hMZH1A6w8UFP7qbmQWw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/16/2017 10:19 AM, Arnd Bergmann wrote:
> On Tue, May 16, 2017 at 3:44 PM, Jes Sorensen <jes.sorensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> On 05/16/2017 07:55 AM, Stanislaw Gruszka wrote:
>>>
>>> On Mon, May 15, 2017 at 10:39:51AM -0400, David Miller wrote:
>>>>
>>>> Passing return values by reference is and always has been a really
>>>> poor way to achieve what these functions are doing.
>>>>
>>>> And frankly, whilst the tool could see what's going on here better, we
>>>> should be making code easier rather than more difficult to audit.
>>>>
>>>> I am therefore very much in favor of Arnd's change.
>>>>
>>>> This isn't even a situation where there are multiple return values,
>>>> such as needing to signal an error and return an unsigned value at the
>>>> same time.
>>>>
>>>> These functions return _one_ value, and therefore they should be
>>>> returned as a true return value.
>>>
>>>
>>> In rt2x00 driver we use poor convention in other kind of registers
>>> accessors like bbp, mac, eeprom. I dislike to changing only rfcsr
>>> accessors and leaving others in the old way. And changing all accessors
>>> would be massive and error prone change, which I'm not prefer either.
>>
>>
>> That's why you do it in multiple smaller patches rather than one ugly giant
>> patch.
> 
> I did  the first step using a search&replace in vim using
> 
> s:\(rt2800_rfcsr_read(.*,.*\), &\(.*\));:\2 = \1);:
> 
> but had to introduce a conversion function
> 
> static void rt2800_rfcsr_readreg(struct rt2x00_dev *rt2x00dev,
>                                  const unsigned int word, u8 *value)
> {
>         *value = rt2800_rfcsr_read(rt2x00dev, word);
> }
> 
> to keep the correct types in place for struct rt2x00debug. I now
> did all the other ones too, and removed that helper again. The
> result in much nicer, but I basically ended up having to do
> the same regex search for all of these at once:
> 
> static void rt2400pci_bbp_read(struct rt2x00_dev *rt2x00dev,
> static void rt2500pci_bbp_read(struct rt2x00_dev *rt2x00dev,
> static void rt2500usb_register_read(struct rt2x00_dev *rt2x00dev,
> static void rt2500usb_register_read_lock(struct rt2x00_dev *rt2x00dev,
> static void rt2500usb_bbp_read(struct rt2x00_dev *rt2x00dev,
> static void _rt2500usb_register_read(struct rt2x00_dev *rt2x00dev,
> static void rt2800_bbp_read(struct rt2x00_dev *rt2x00dev,
> static void rt2800_eeprom_read(struct rt2x00_dev *rt2x00dev,
> static void rt2800_rfcsr_readreg(struct rt2x00_dev *rt2x00dev,
> static void rt2800_bbp_dcoc_read(struct rt2x00_dev *rt2x00dev,
> void (*register_read)(struct rt2x00_dev *rt2x00dev,
> void (*register_read_lock)(struct rt2x00_dev *rt2x00dev,
> static inline void rt2800_register_read(struct rt2x00_dev *rt2x00dev,
> static inline void rt2800_register_read_lock(struct rt2x00_dev *rt2x00dev,
> static inline void rt2x00_rf_read(struct rt2x00_dev *rt2x00dev,
> static inline void rt2x00_eeprom_read(struct rt2x00_dev *rt2x00dev,
> void (*read)(struct rt2x00_dev *rt2x00dev, \
> static inline void rt2x00mmio_register_read(struct rt2x00_dev *rt2x00dev,
> static inline void _rt2x00_desc_read(__le32 *desc, const u8 word, __le32 *value)
> static inline void rt2x00_desc_read(__le32 *desc, const u8 word, u32 *value)
> static inline void rt2x00usb_register_read(struct rt2x00_dev *rt2x00dev,
> static inline void rt2x00usb_register_read_lock(struct rt2x00_dev *rt2x00dev,
> static void rt61pci_bbp_read(struct rt2x00_dev *rt2x00dev,
> static void rt73usb_bbp_read(struct rt2x00_dev *rt2x00dev,
> 
> and that ended up as a 300KB patch [1]. Splitting it up is clearly possibly,
> but I fear that would be more error-prone as we then need to add
> those helpers for the other debug stuff as well, and remove it again
> afterwards.

True - if the automatic conversion works without automatic intervention, 
I am less worried about it. Personally I would still focus on converting 
one function at a time to reduce the impact of each patch.

Cheers,
Jes
