From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Allow TCP connections to cache SYN packet for userspace
 inspection
Date: Fri, 01 May 2015 13:23:20 -0700
Message-ID: <1430511800.3711.138.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430502237-5619-1-git-send-email-emunson@akamai.com>
	 <1430505777.3711.135.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34ftz_wDoPwcJg_cMQu4QtnBJF-=d+gF5ieTA=d=r31-Q@mail.gmail.com>
	 <20150501201417.GB6113@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150501201417.GB6113-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-05-01 at 16:14 -0400, Eric B Munson wrote:
> On Fri, 01 May 2015, Tom Herbert wrote:
> 
> > On Fri, May 1, 2015 at 11:42 AM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > > On Fri, 2015-05-01 at 13:43 -0400, Eric B Munson wrote:
> > >> In order to enable policy decisions in userspace, the data contained in
> > >> the SYN packet would be useful for tracking or identifying connections.
> > >> Only parts of this data are available to userspace after the hand shake
> > >> is completed.  This patch exposes a new setsockopt() option that will,
> > >> when used with a listening socket, ask the kernel to cache the skb
> > >> holding the SYN packet for retrieval later.  The SYN skbs will not be
> > >> saved while the kernel is in syn cookie mode.
> > >>
> > >> The same option will ask the kernel for the packet headers when used
> > >> with getsockopt() with the socket returned from accept().  The cached
> > >> packet will only be available for the first getsockopt() call, the skb
> > >> is consumed after the requested data is copied to userspace.  Subsequent
> > >> calls will return -ENOENT.  Because of this behavior, getsockopt() will
> > >> return -E2BIG if the caller supplied a buffer that is too small to hold
> > >> the skb header.
> > >>
> > >> Signed-off-by: Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
> > >> Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
> > >> Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
> > >> Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
> > >> Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> > >> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > >> Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > >> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > >> ---
> > >
> > > We have a similar patch here at Google, but we do not hold one skb and
> > > dst per saved syn. That can be ~4KB for some drivers.
> > >
> > > Only a kmalloc() with the needed part (headers), usually less than 128
> > > bytes. We store the length in first byte of this allocation.
> > >
> > > This has a huge difference if you want to have ~4 million request socks.
> > >
> > +1 on kmalloc solution. I posted a similar patch a couple of years ago
> > https://patchwork.ozlabs.org/patch/146034/. There was pushback on
> > memory usage and this having to narrow of a use case.
> > 
> > Tom
> > 
> 
> I cached the skb largely to take advantage of the built in reference
> counting and avoid having to manage allocating memory and ownership of
> said memory.  For V2, how about I keep the skb reference in the request
> structure and kmalloc() a buffer, to be owned by the tcp sock structure,
> when the new tcp socket is created?  This would also simplify the
> getsockopt() so that the data was available to all callers until the
> socket is closed.

Please do not keep a reference on skb. This has a too big cost.

Have you read that we plan to have up to 4 or 10 million request socks ?

skb also holds a dst.

We can upstream our implementation (based on Tom prior patch), we have
been using it more than 2 years with success.
