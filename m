From: jamal <hadi@cyberus.ca>
Subject: Re: IMQ / new Dummy device post.
Date: 15 Apr 2004 23:52:33 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1082087553.1035.287.camel@jzny.localdomain>
References: <407E5905.9070108@dsl.pipex.com>
	 <1082031313.1039.13.camel@jzny.localdomain>
	 <407EE3E5.8060200@dsl.pipex.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <407EE3E5.8060200@dsl.pipex.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-04-15 at 15:35, Andy Furniss wrote:
> jamal wrote:

> What I want to know is what state IP packets will be in if I

Just to be sure, this is not specific just to IP; it could be ARP, IPX,
v6 etc.

>  
> filter/shape with dummy - In my case I would need them to have been 
> demasqued so I can tell the difference between local and to be forwarded 
> ingress traffic.

The packets are grabbed before NAT on the way in and after NAT on the
way out. 
Coming from non-local machines before NAT you can redirect to a dummy
device; and also be able to redirect on their way back to the non-local;
to use the example i posted earlier:

----
$TC qdisc add dev dummy0 root handle 1: prio 
$TC qdisc add dev dummy0 parent 1:1 handle 10: sfq
$TC qdisc add dev dummy0 parent 1:2 handle 20: tbf rate 20kbit buffer
1600 limit
 3000
$TC qdisc add dev dummy0 parent 1:3 handle 30:
sfq                              
  
$TC filter add dev dummy0 protocol ip pref 1 parent 1: handle 1 fw
classid 1:1
$TC filter add dev dummy0 protocol ip pref 2 parent 1: handle 2 fw
classid 1:2

ifconfig dummy0 up

#deal with ingress of eth0 first
$TC qdisc add dev eth0 ingress

# redirect all IP packets arriving from 10.0.0.21/24 in eth0 to dummy0 
# use mark 1 --> puts them onto class 1:1 of dummy
#
$TC filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
match ip src 10.0.0.21/24 flowid 1:1 \
action ipt -j MARK --set-mark 1 \
action mirred egress redirect dev dummy0

#deal with egress of eth0
$TC qdisc add dev eth0 root handle 1: prio 

# redirect all IP packets going to 10.0.0.21/24 in eth0 to dummy0 
# use mark 2 --> puts them onto class 1:2 of dummy
#
$TC filter add dev eth0 parent 1:0 protocol ip prio 10 u32 \
match ip dst 10.0.0.21/24 flowid 1:1 \
action ipt -j MARK --set-mark 2 \
action mirred egress redirect dev dummy0
-----

I havent tested the above but it should work (sans syntax bugs). If it
doesnt then we have a bug that needs fixing.

> Ie. where on the KPTD would dummy be - IMQ appears twice and by using 
> the IMQ nat patch I can use the prerouting one to filter/shape the 
> packets after they are denatted.
> 

does the above help?

cheers,
jamal
