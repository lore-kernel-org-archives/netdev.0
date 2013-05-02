From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next 0/6] Allow bridge to function in
 non-promisc mode
Date: Thu, 2 May 2013 11:14:14 -0700
Message-ID: <20130502111414.0ae8f216@nehalam.linuxnetplumber.net>
References: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
	<20130502102331.43728912@nehalam.linuxnetplumber.net>
	<5182A531.2030900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org, mst@redhat.com
To: vyasevic@redhat.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <5182A531.2030900@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 02 May 2013 13:41:05 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> On 05/02/2013 01:23 PM, Stephen Hemminger wrote:
> > Doing research on another problem, I noticed that this would
> > break user mode spanning tree (RSTP) code.
> >
> > The daemon assumes that bridge is promicious mode and therefore
> > will receive all link-level multicast packets.
> >
> 
> Just took another look at RSTP code and I see that's its using
> a packet socket with filter to catch STP frames.
> 
> Would setting IFF_ALL_MULTI solve the problem?  STP packets
> are all multicast.
> 
> Thanks
> -vlad

See opening of the packet.c in RSTP daemon.

/*
 * Open up a raw packet socket to catch all 802.2 packets.
 * and install a packet filter to only see STP (SAP 42)
 *
 * Since any bridged devices are already in promiscious mode
 * no need to add multicast address.
 */
int packet_sock_init(void)
{
	int s;
	struct sock_fprog prog = {
		.len = sizeof(stp_filter) / sizeof(stp_filter[0]),
		.filter = stp_filter,
	};

	s = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_802_2));
	if (s < 0) {
		ERROR("socket failed: %m");
		return -1;
	}

	if (setsockopt(s, SOL_SOCKET, SO_ATTACH_FILTER, &prog, sizeof(prog)) < 0) 
		ERROR("setsockopt packet filter failed: %m");
