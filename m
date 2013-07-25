From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/1] TX throttling bug-fixing patch of AX88179_178A
Date: Thu, 25 Jul 2013 04:01:41 -0700
Message-ID: <1374750101.23313.16.camel@edumazet-glaptop>
References: <1374311809-4155-1-git-send-email-freddy@asix.com.tw>
	 <1374512879.4990.19.camel@edumazet-glaptop>
	 <CANEJEGvPc56ePP=_bxfA4PZfsM3vw=MsRjbWwrFBC3eP-GtzZg@mail.gmail.com>
	 <1374518312.1635.29.camel@bwh-desktop.uk.level5networks.com>
	 <1374518841.4990.26.camel@edumazet-glaptop>
	 <1374522471.1635.48.camel@bwh-desktop.uk.level5networks.com>
	 <1374559827.4990.143.camel@edumazet-glaptop>
	 <CACVXFVN0eN9E9efr8UdqFz68-emHa2o-RQ0RYfazEq8f=qxkLQ@mail.gmail.com>
	 <1374729058.23313.8.camel@edumazet-glaptop>
	 <CACVXFVNyFk0Zpi4tC0ENiq8RcrtrjYW-Dhs+A56+Pw4BKm8y8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ASIX Louis =?UTF-8?Q?=5B=E8=98=87=E5=A8=81=E9=99=B8=5D?=
	<louis-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>, Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVNyFk0Zpi4tC0ENiq8RcrtrjYW-Dhs+A56+Pw4BKm8y8A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-07-25 at 13:25 +0800, Ming Lei wrote:
> On Thu, Jul 25, 2013 at 1:10 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > On Thu, 2013-07-25 at 10:28 +0800, Ming Lei wrote:
> >
> >>
> >> It depends if size of sg buffer(except for last one) in the sg list can be
> >> divided by usb endpoint's max packet size(512 or 1024), at least there
> >> is the constraint:
> >>
> >> http://git.kernel.org/cgit/linux/kernel/git/gregkh/usb.git/commit/?h=usb-next&id=10e232c597ac757e7f8600649f7e872e86de190f
> >>
> >> I am wondering if network stack can meet that.  If not, it might be a
> >> bit difficult
> >> because lots of USB host controller don't support that, and driver may have
> >> to support SG and non-SG at the same time for working well on all HCs.
> >
> > I do not see the problem.
> >
> > If one skb has 2 fragments of 32KB, couldn't they be split into 64 1K
> > segments by the device driver ?
> 
> OK, if length of fragments of all SKBs from network stack can always guarantee
> to be divided by 1024, that is fine,  seems I worry about too much, :-)

Unfortunately, there is no such guarantee. TSO permits sendfile() zero
copy operation, so the frags can be of any size, any offset...

In this mode, the first element (skb->head) will typically contains the
headers, and there are way below 512 bytes.

So even with lowering netdev->gso_max_size under PAGE_SIZE, most of the
packets will need to be copied into a single segment.



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
