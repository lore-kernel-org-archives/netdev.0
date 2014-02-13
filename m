From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: remove generic hard_header_len check
Date: Thu, 13 Feb 2014 12:36:30 +0100
Message-ID: <87y51f2qip.fsf@nemi.mork.no>
References: <1392249836-27151-1-git-send-email-emilgoode@gmail.com>
	<87fvnn4c2k.fsf@nemi.mork.no> <20140213112016.GA4245@lianli>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	Oliver Neukum <oneukum@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <edumazet@google.com>,
	Ming Lei <ming.lei@canonical.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Liu Junliang <liujunliang_ljl@163.com>,
	Octavian Purdila <octavian.purdila@intel.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Emil Goode <emilgoode@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140213112016.GA4245@lianli> (Emil Goode's message of "Thu, 13
	Feb 2014 12:20:16 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Emil Goode <emilgoode@gmail.com> writes:

> Yes I should have put a comment in the changelog about this. All skbs=
 that
> are passed to rx_process have their state set to rx_cleanup and just =
because
> the skb was cloned doesn't mean that we should free the original in a
> different way. As it is I think we are acctually missing a call to
> usb_free_urb that is called on the common rx_cleanup path.

Yes, I wondered about that as well, thinking that this part actually
should be a separate patch for net+stable.

But then I wondered how we could possibly have had a bug like that
living here for so long, and the answer is we haven't.  You don't want
to free the URB.  It is already resubmitted with a different skb as its
buffer.  The call to usb_free_urb in the rx_cleanup path is there only
for the cases where the URB is not resubmitted. The rx_complete callbac=
k
is controlling this by updating entry->urb as appropriate.  So it will
always be NULL if rx_process is called, and the call to usb_free_urb ha=
s
no effect.

Rearranging this code to always take the same cleanup path is still a
very nice cleanup IMHO.


Bj=C3=B8rn
