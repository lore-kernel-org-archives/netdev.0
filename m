From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: masquerading failure for at least icmp and tcp+sack on amd64
Date: Wed, 07 Sep 2005 14:39:20 +0200
Message-ID: <431EDF78.8060505@trash.net>
References: <20050907052057.09714a4c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Marc Lehmann <schmorp@schmorp.de>
In-Reply-To: <20050907052057.09714a4c.akpm@osdl.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> I recently upgraded a 32 bit machine to a new amd64 board+cpu. I took the
> same kernel (2.6.13-rc7) and just recompiled it for 64 bit, plus upgraded
> userspace to 64 bit.
> 
> Firewall config stayed the same.
> 
> Problem: neither ping nor tcp was being masqueraded properly. I created
> the following test-set-up:
> 
>    iptables -t mangle -F
>    iptables -t filter -F
>    iptables -t nat -F
>    iptables -t nat -A POSTROUTING -p all -s 10.0.0.0/8 -d \! 10.0.0.0/8 -j MASQUERADE
> 
> i..e the above masquerade rule should be the only firewall rule, and all
> fules shoul[d have policy ACCEPT.
> 
> The effect was that tcp packets and icmp packets coming from 10.0.0.1 on
> interface eth0 were properly masqueraded on the outgoing "inet" interface
> (ppp0 renamed):
> 
> eth0:
>    19:17:24.364351 IP 10.0.0.1.44320 > 129.13.162.95.80: S 3745828676:3745828676(0) win 5840 <mss 1460,nop,nop,sackOK>
> 
> inet:
>    19:17:24.364505 IP 84.56.237.68.44320 > 129.13.162.95.80: S 3745828676:3745828676(0) win 5840 <mss 1452,nop,nop,sackOK>
>    19:17:24.378029 IP 129.13.162.95.80 > 84.56.237.68.44320: S 3777391404:3777391404(0) ack 3745828677 win 5840 <mss 1460,nop,nop,sackOK>
>    19:17:24.378103 IP 84.56.237.68.44320 > 129.13.162.95.80: R 3745828677:3745828677(0) win 0
> 
> However, the reverse packets were rejected. ip_conntrack showed this:
> 
>    tcp      6 52 SYN_SENT src=10.0.0.1 dst=129.13.162.95 sport=44320 dport=80 [UNREPLIED] src=129.13.162.95 dst=84.56.237.68 sport=80 dport=44320 mark=0 use=1

It seems ip_conntrack did not like the SYN/ACK and marked it as invalid,
NAT leaves the packet alone and the firewall resets the connection.
Please try if loading the ipt_LOG module and executing
"echo 255 > /proc/sys/net/ipv4/netfilter/ip_conntrack_log_invalid"
gives more information

> Weird obervation 2:
> 
> Some sites could be connected to with TCP. It turned out that those
> sites did not support TCP SACK. Indeed, turning off SACK either on the
> remote side of a connection or on the origonator side resulted in workign
> masquerading:
> 
> eth0:
>    19:23:29.928470 IP 10.0.0.1.45611 > 129.13.162.95.80: S 4113365634:4113365634(0) win 5840 <mss 1460>
>    19:23:29.942246 IP 129.13.162.95.80 > 10.0.0.1.45611: S 4161877683:4161877683(0) ack 4113365635 win 5840 <mss 1460>
>    19:23:29.942313 IP 10.0.0.1.45611 > 129.13.162.95.80: . ack 1 win 5840
> 
> inet:
>    19:23:29.928249 IP 84.56.237.68.45611 > 129.13.162.95.80: S 4113365634:4113365634(0) win 5840 <mss 1452>
>    19:23:29.942199 IP 129.13.162.95.80 > 84.56.237.68.45611: S 4161877683:4161877683(0) ack 4113365635 win 5840 <mss 1460>
>    19:23:29.942332 IP 84.56.237.68.45611 > 129.13.162.95.80: . ack 1 win 5840
> 
> However, ICMP still is not masqueraded.

Please also try this again with logging enabled.

> Kernels that worked:
> 
>    2.6.13-rc7, 2.6.12.5, 2.6.11 and lower, compiled for x86 with gcc-3.4
> 
> Kernels that don't work:
> 
>    2.6.13-rc7 (compiled with gcc-3.4 and 4.0.2 debian), 2.6.13 (gcc-4.02)

Can you retest with 2.6.12.5 on 64bit so we can see if it is a new
problem?

> Kernel configuration was exactly the same for the 2.6.13-rc7 kernels,
> modulo the cpu and architectrue selections.
> 
> I have a somewhat nontrivial source routing set-up on that machine that I
> could document more if that could be a possible reason for that problem. I
> am confident that this is not a configuration error, as the configuraiton
> worked basically unchanged since the 2.4 days, and I am confident it's not
> a iptables setup problem either, as I can reproduce it with empty rules
> except for the masquerading rule.

So far I don't think its related to routed.
