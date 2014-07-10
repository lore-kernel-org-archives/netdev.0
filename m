From: Olivier Sobrie <olivier@sobrie.be>
Subject: Re: [PATCH 2/2] hso: fix deadlock when receiving bursts of data
Date: Thu, 10 Jul 2014 16:28:48 +0200
Message-ID: <20140710142848.GA28056@hposo>
References: <1404723967-24245-1-git-send-email-olivier@sobrie.be>
 <1404723967-24245-2-git-send-email-olivier@sobrie.be>
 <20140708.161633.2130069042930765600.davem@davemloft.net>
Reply-To: Olivier Sobrie <olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: j.dumon@option.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140708.161633.2130069042930765600.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Tue, Jul 08, 2014 at 04:16:33PM -0700, David Miller wrote:
> From: Olivier Sobrie <olivier@sobrie.be>
> Date: Mon,  7 Jul 2014 11:06:07 +0200
> 
> > When the module sends bursts of data, sometimes a deadlock happens in
> > the hso driver when the tty buffer doesn't get the chance to be flushed
> > quickly enough.
> > 
> > To avoid this, first, we remove the endless while loop in
> > put_rx_bufdata() which is the root cause of the deadlock.
> > Secondly, when there is no room anymore in the tty buffer, we set up a
> > timer of 100 msecs to give a chance to the upper layer to flush the tty
> > buffer and make room for new data.
> > 
> > Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
> 
> I agree with the feedback you've been given in that adding a delay
> like this is really not a reasonable solution.
> 
> Why is it so difficult to make the event which places the data there
> trigger to necessary calls to pull the data out of the URB transfer
> buffer?
> 
> This should be totally and completely event based.

The function put_rxbuf_data() is called from the urb completion handler.
It puts the data of the urb transfer in the tty buffer with
tty_insert_flip_string_flags() and schedules a work queue in order to
push the data to the ldisc.
Problem is that we are in a urb completion handler so we can't wait
until there is room in the tty buffer.
An option I see is: If tty_insert_flip_string_flags() returns 0, start a
workqueue that will insert the remaining data in the tty buffer and then
restart the urb. But I'm not convinced that it is a good solution.
I should miss something...

In put_rxbuf_data(), when tty_insert_flip_string_flags() returns 0, would
it be correct to set the TTY_THROTTLED flag? I assume not...

I'll have a look in other drivers how such cases are handled.

Thanks,

-- 
Olivier
