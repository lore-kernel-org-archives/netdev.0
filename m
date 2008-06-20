From: Travis Stratman <tstratman@emacinc.com>
Subject: Re: data received but not detected
Date: Fri, 20 Jun 2008 12:10:59 -0500
Message-ID: <1213981859.9245.133.camel@localhost.localdomain>
References: <1213740538.5771.192.camel@localhost.localdomain>
	 <48583B37.5070708@candelatech.com>
	 <1213743506.5771.220.camel@localhost.localdomain>
	 <20080618062857.GA3598@2ka.mipt.ru>
	 <1213917029.9245.86.camel@localhost.localdomain>
	 <20080620060219.GA22784@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.emacinc.com ([63.245.244.68]:42955 "EHLO mail.emacinc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752591AbYFTRNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 13:13:16 -0400
In-Reply-To: <20080620060219.GA22784@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-06-20 at 10:02 +0400, Evgeniy Polyakov wrote:
> On Thu, Jun 19, 2008 at 06:10:29PM -0500, Travis Stratman (tstratman@emacinc.com) wrote:
> > Initially, I had run wireshark on my PC and connected it to one of the
> > embedded boards (the issue still shows up in this case). I did some more
> > testing today where I ran tcpdump on both of the boards connected with a
> > cross-over cable until the application froze. What I was able to find
> > was that the first 1 or 2 hangups are corrected after 4 or 5 seconds
> > because the boards send an ARP request when data communication stops.
> > This causes communication to start up again. No packets are ever lost or
> > corrupted, they just don't appear to the application until something
> > else happens on the network.

Also note that it just needs to be data that the board receives, it does
not have to come in on the same port (ARPs, ICMP pings, broadcast
packets all force the data to be recognized).

> This looks like wakeup missing/not accounted (probalby by application).
> Does your application use poll()? If no, can you add it into the
> receiving loop and check its output? Or even add a signal handler for
> harmless signal like usr1 and put poll() call with 0 timeout there, so
> when system will freeze you could check what poll() returns by that
> signal.
Thanks. 

Initially the application was just using a blocking recvfrom() call. I
changed to poll() and non-blocking recvfrom (MSG_DONTWAIT) today, and
poll() always times out when the lockup occurs. I also tried using an
FIONREAD ioctl on the socket and actually saw fairly decent results
using code like this:
--function--
static inline int is_data(int socket)
{
	int num_bytes;
	ioctl(socket, FIONREAD, &num_bytes);
	return num_bytes;
}
-- then before each recvfrom --
while (!is_data(recv_socket)) {usleep(1);}

It ran for about an hour before it froze. I'm not sure why this would
give me better results than poll(), that is something that I'm looking
into.

I also noticed that when I run iperf between the two ARM boards on a
xover cable, I _always_ see at least one dropped packet reported by
iperf. For bandwidths that are below 50m it is almost always 1, but
never 0 dropped. When I run it between my PC and an ARM board, I don't
(generally) see any dropped packets until I exceed 50m for the bandwidth
setting. This probably doesn't mean anything, but it is interesting.


Thanks,

Travis


