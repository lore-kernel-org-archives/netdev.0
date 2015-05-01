From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH] Allow TCP connections to cache SYN packet for userspace inspection
Date: Fri, 1 May 2015 13:28:52 -0700
Message-ID: <CALCETrWbmdyX4zC55xb29Ko4XRqnrA-coc047CuiTaZFPKhbYA@mail.gmail.com>
References: <1430502237-5619-1-git-send-email-emunson@akamai.com>
 <CALCETrWi6h3DRu6Z8jJ_-MiWqRRyKZHntpJFNON=GpAjMDYXmQ@mail.gmail.com> <20150501200136.GA6113@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Network Development <netdev@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric B Munson <emunson@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150501200136.GA6113@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 1, 2015 at 1:01 PM, Eric B Munson <emunson@akamai.com> wrote:
> On Fri, 01 May 2015, Andy Lutomirski wrote:
>
>> On Fri, May 1, 2015 at 10:43 AM, Eric B Munson <emunson@akamai.com> wrote:
>> > In order to enable policy decisions in userspace, the data contained in
>> > the SYN packet would be useful for tracking or identifying connections.
>> > Only parts of this data are available to userspace after the hand shake
>> > is completed.  This patch exposes a new setsockopt() option that will,
>> > when used with a listening socket, ask the kernel to cache the skb
>> > holding the SYN packet for retrieval later.  The SYN skbs will not be
>> > saved while the kernel is in syn cookie mode.
>> >
>> > The same option will ask the kernel for the packet headers when used
>> > with getsockopt() with the socket returned from accept().  The cached
>> > packet will only be available for the first getsockopt() call, the skb
>> > is consumed after the requested data is copied to userspace.  Subsequent
>> > calls will return -ENOENT.  Because of this behavior, getsockopt() will
>> > return -E2BIG if the caller supplied a buffer that is too small to hold
>> > the skb header.
>>
>> What's the purpose and what headers are you returning?
>
> Currently the ethernet, IP, and TCP headers are being returned.  The IP
> and TCP headers will be used by userspace to make decisions on how to
> handle incoming connections.  The ethernet headers are being returned
> for completeness, I would be fine not including them in what is copied
> if that is a concern, however the team requesting this change here
> requires the IP and TCP headers.
>
>>
>> There was a bit of a mixup with tx timestamps where the set of headers
>> returned was possibly excessive and incompletely thought out the first
>> time around.
>
> With this in mind, we could drop copying the ethernet headers and simply
> hold onto the IP and TCP headers.

That's probably better.  If nothing else, you avoid breaking userspace
when you're not using Ethernet.

--Andy
