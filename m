From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: Fri, 25 Mar 2005 19:59:46 +0000
Message-ID: <42446DB2.9070809@dsl.pipex.com>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <1110416767.1111.76.camel@jzny.localdomain>	 <025501c52552$2dbf87c0$6e69690a@RIMAS>	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>	 <1111410890.1092.195.camel@jzny.localdomain>	 <423F41AD.3010902@dsl.pipex.com>	 <1111444869.1072.51.camel@jzny.localdomain>	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>	 <42408998.5000202@dsl.pipex.com>	 <1111550254.1089.21.camel@jzny.localdomain>	 <4241C478.5030309@dsl.pipex.com>	 <1111607112.1072.48.camel@jzny.localdomain>	 <4241D764.2030306@dsl.pipex.com>	 <1111612042.1072.53.camel@jzny.localdomain>	 <4241F1D2.9050202@dsl.pipex.com>  <4241F7F0.2010403@dsl.pipex.com>	 <1111625608.1037.16.camel@jzny.localdomain> <424212F7.10106@dsl.pipex.com>	 <1111663947.1037.24.camel@jzny.localdomain>	 <1111665450.1037.27.camel@jzny.localdomain>	 <4242DFB5
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: hadi@cyberus.ca
In-Reply-To: <1111749220.1092.457.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

> I gotta give it to you - you have helped isolate more bugs in this one
> session than all others in the past summed up.

LOL - there may be more to come, though I haven't used CONNMARK before 
and may be missing something about it - and maybe there is a tc way to 
look at connmark anyway?

Works as I expect -

iptables -A POSTROUTING -t mangle -j CONNMARK --set-mark 1
iptables -A INPUT -t mangle -m mark --mark 1
iptables -A PREROUTING -t mangle -j CONNMARK --restore-mark

I ping a lan pc and I get matches for the marked incoming packets in INPUT.

If I do

iptables -A POSTROUTING -t mangle -j CONNMARK --set-mark 1
iptables -A INPUT -t mangle -m mark --mark 1
tc qdisc add dev eth0 ingress
tc filter add dev eth0 parent ffff: protocol ip prio 6 u32 match ip src 
0/0 flowid 1:1 action ipt -j CONNMARK --restore-mark

It doesn't mark the packets.

3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.355/0.415/0.529/0.081 ms
[root@amd /home/andy/Qos]# tc -s filter ls dev eth0 parent ffff:
filter protocol ip pref 6 u32
filter protocol ip pref 6 u32 fh 800: ht divisor 1
filter protocol ip pref 6 u32 fh 800::800 order 2048 key ht 800 bkt 0 
flowid 1:1  (rule hit 3 success 3)
   match 00000000/00000000 at 12 (success 3 )
         action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
         target CONNMARK restore
         index 2 ref 1 bind 1 installed 44 sec used 31 sec
         Action statistics:
         Sent 252 bytes 3 pkt (dropped 0, overlimits 0 requeues 0)
         rate 0bit 0pps backlog 0b 0p requeues 0

[root@amd /home/andy/Qos]# iptables -L -t mangle -v
Chain PREROUTING (policy ACCEPT 364 packets, 401K bytes)
  pkts bytes target     prot opt in     out     source 
destination

Chain INPUT (policy ACCEPT 364 packets, 401K bytes)
  pkts bytes target     prot opt in     out     source 
destination
     0     0            all  --  any    any     anywhere 
anywhere            MARK match 0x1

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
  pkts bytes target     prot opt in     out     source 
destination

Chain OUTPUT (policy ACCEPT 300 packets, 19702 bytes)
  pkts bytes target     prot opt in     out     source 
destination

Chain POSTROUTING (policy ACCEPT 300 packets, 19702 bytes)
  pkts bytes target     prot opt in     out     source 
destination
     3   252 CONNMARK   all  --  any    any     anywhere 
anywhere            CONNMARK set 0x1

Andy.
