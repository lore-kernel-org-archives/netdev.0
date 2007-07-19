From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 20:28:10 +0100
Message-ID: <20070719202810.4d9ee230@oldman>
References: <839334.9648.qm@web56605.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>,
	Krzysztof Halasa <khc@pm.waw.pl>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: andrei radulescu-banu <iubica2@yahoo.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965818AbXGST3c@vger.kernel.org>
In-Reply-To: <839334.9648.qm@web56605.mail.re3.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jul 2007 11:20:43 -0700 (PDT)
andrei radulescu-banu <iubica2@yahoo.com> wrote:

> > [Ben] If tcpdump and/or bridging needs to disable the hw-accel, then it can 
> explicitly do so by some API.  That is better than overloading
> the promisc flag in my opinion.  
> 
> I guess I could be persuaded in the end. But let me still play devil advocate. The semantics of 'promiscuous', in my opinion, mean 'receive everything', including vlan.
> 
> > [Ben] This is especially true since promisc 
> is not easily readable by user-space and things like tcpdump
> cannot have full control of promisc (if a mac-vlan has the NIC in 
> promisc mode, for instance, then tcpdump can never disable it.)
> 
> I agree with all the above. For example when you run 'ifconfig' during 'tcpdump', the interface does not have the promiscuous flag set!! 

In kernel it is a nice atomic counter, no problem.

> 
> This confused me for a while, until I realized that tcpdump's packet socket was using an obscure packet_dev_mc() API (af_packet.c) to get the interface in promiscuous mode. The reason for this is that packet_mc_add() implements a reference counted mechanism for promiscuous. So that:
> - starting tcpdump instance 1 sets promiscuous mode
> - starting tcpdump instance 2 bumps the ref count in packet_mc_add()
> - killing tcpdump instance 1 bumps down the ref count, the interface stays promiscuous
> - killing tcpdump instance 2 truly clear promiscuous mode.
> 
> The trick here is that when you kill tcpdump, the kernel clears the packet socket, and in process bumps down the ref count. Had tcpdump manually set/cleared the promisc flag, the interface would have stayed promisc after tcpdump was killed.
> 
> (The mac-vlan driver must have this corner problem as well. If a mac-vlan interface is disabled while tcpdump runs, it may yank promiscuousness from under tcpdump.)

The kernel has no such problem

> So if you want to create an ethtool API to set vlan-promiscuous mode, one problem to grapple is that we need a similar mechanism to the above, so you can run two concurrent tcpdump's (or tcpdump while bridging vlans) and the vlan-promiscuous mode gets set correctly each time.  For tcpdump at least, the new ethtool API needs to be called from packet_mc_add().
