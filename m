From: "David S. Miller" <davem@redhat.com>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Mon, 9 Feb 2004 13:58:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209135843.42b5b67e.davem@redhat.com>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 8 Feb 2004 22:44:05 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> +				if (skb->stamp.tv_sec) {

Julian, do you understand what this check is for?

If it is zero, this means we are being reinvoked via the delayed proxy queue.
It means that some previously delayed response has been kicked so that we
should respond to it right now, with no delay, no matter what.

Otherwise you could loop delaying the thing forever.  If there is a case
where some pneigh ARP request should be evaluated multiple times, such
a change belongs in the pneigh_*() code not here in ipv4 arp processing.

The exact path is:

1) All input packets get skb->stamp.tv_sec assigned to in net/core/dev.c at
   the waaaay beginning of input packet processing...

2) Therefore the first time skb goes through arp_rcv() skb->tv_sec will be
   non-zero.

3) If it is pneigh_enqueue()'d, then skb->stamp.tv_sec will be set to zero
   therefore upon reprocessing by arp_rcv() it will be seen as zero and this
   is how such a state is detected.

Yes, I hate all of these overloaded meanings of skb->stamp.tv_* as much as
anyone else.

This is my contribution wrt. this suggested patch today, it's your turn to
make some commentary Julian :-)
