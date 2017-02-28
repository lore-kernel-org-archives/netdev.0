From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Tue, 28 Feb 2017 09:26:32 +0100
Message-ID: <20170228082632.GA14857@localhost>
References: <20170207140144.GA11233@localhost>
 <02874ECE860811409154E81DA85FBB5857D6DC87@ORSMSX115.amr.corp.intel.com>
 <CAF=yD-JLiABx6TcVg_8mS5ZhomRaZ+cZ8edx00hJNG8PDrsSjg@mail.gmail.com>
 <20170227152339.GB12043@localhost>
 <CAF=yD-JJ2nMYg1soRzCv2CKH0c_i2+Ku-UK8-mMYFtbfbn__kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>, Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42004 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751055AbdB1I14 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 03:27:56 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-JJ2nMYg1soRzCv2CKH0c_i2+Ku-UK8-mMYFtbfbn__kw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2017 at 07:01:54PM -0500, Willem de Bruijn wrote:
> On Mon, Feb 27, 2017 at 10:23 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > On Tue, Feb 07, 2017 at 02:32:04PM -0800, Willem de Bruijn wrote:
> >> >> 4) allow sockets to use both SW and HW TX timestamping at the same time

> > Do we need a new option for this?
> 
> Similar to OPT_TSONLY or OPT_ID, but to signal the intent of
> receiving both timestamps. Yes, agreed.

Ok. Thanks.

> > With this change I'm getting two error messages per transmission, but
> > it looks like it may need some additional changes.
> >
> > If the first error message is received after the HW timestamp was
> > captured,
> 
> When does this happen? The first timestamp is generated from
> skb_tx_timestamp in the device driver's ndo_start_xmit before
> passing the packet to the NIC, the second when the device
> driver cleans the tx descriptor on completion.

As I understand it, it happens when the first skb (created by the
skb_tx_timestamp() call) is received by the application after the
driver called skb_tstamp_tx() with the HW timestamp. The SW timestamps
are separate, but the HW timestamp is shared between clones. It
probably doesn't happen with the TSONLY option as it allocates a new
skb. When I print timestamps from scm_timestamping I see a mix of two
cases:

TX 1488268812.193945472 0.000000000 1488286813.273760139
TX 0.000000000 0.000000000 1488286813.273760139
RX 1488268812.354356188 0.000000000 1488286813.434096389

TX 1488268816.364407934 0.000000000 0.000000000
TX 0.000000000 0.000000000 1488286817.444251014
RX 1488268816.525150589 0.000000000 1488286817.604749889

In the first case I assume the HW timestamp was saved before the first
error message was received, so both error messages have the same HW
timestamp, but only one has the SW timestamp. In the second case, the
HW timestamp was saved later, so there is one message with SW
timestamp and one message with HW timestamp.

>From the application point of view it would make sense if in the first
case there was only one error message containing both timestamps. I'm
not sure how easy/safe it would be to drop the second skb. The other
approach would be to not put HW timestamp in the first message when
this "dual TX timestamping" option is enabled, so each error message
has only one timestamp.

> Is this for drivers that do not have skb_tx_timestamp, as you
> mention below? Then the solution is to add that call.

FWIW, I saw that with the e1000e driver after I made the
skb_tx_timestamp() call unconditional.

> > it contains both timestamps as the HW timestamp is in the
> > shared info of the skb. Is it possible it could contain a partially
> > updated HW timestamp? I'm not sure how locking works here. Is
> > scm_timestamping actually allowed to contain more than one timestamp?
> > The timestamping.txt document says "Only one field is non-zero at any
> > time.", but that wasn't true even before if both SW and HW RX
> > timestamping was enabled.

-- 
Miroslav Lichvar
