From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [ANNOUNCE] nf-hipac v0.8 released
Date: Wed, 2 Jul 2003 08:30:07 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307020826530.23232-100000@netcore.fi>
References: <3EFF1349.6020802@hipac.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Bellion and Thomas Heinz <nf@hipac.org>
In-Reply-To: <3EFF1349.6020802@hipac.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Thanks for your clarification.  We've also conducted some tests with 
bridging firewall functionality, and we're very pleased with nf-hipac's 
performance!  Results below.

In the measurements, tests were run through a bridging Linux firewall,
with a netperf UDP stream of 1450 byte packets (launched from a different
computer connected with gigabit ethernet), with a varying amount of
filtering rules checks for each packet.

I don't have the specs of the Linux PC hardware handy, but I recall 
they're *very* highend dual-P4's, like 2.4Ghz, very fast PCI bus, etc.  
Shouldn't be a factor here.

1. Filtering based on source address only, for example:
   $fwcmd -A $MAIN -p udp -s 10.0.0.1   -j DROP
   ...
   $fwcmd -A $MAIN -p udp -s 10.0.3.255 -j DROP
   $fwcmd -A $MAIN -p udp               -j ACCEPT

  Results:
  rules     | plain NF               | NF-HIPAC
            | sent       | got thru  | sent       | got thru  |
      (n.o) |   (Mbit/s) |  (Mbit/s) |   (Mbit/s) |  (Mbit/s) |
  -------------------------------------------------------------
          0 |     956,00 |    953,24 |     956,00 |    953,24 |
        512 |     956,00 |    800,68 |     956,46 |    952,81 |
       1024 |     956,00 |    472,78 |     956,46 |    952,81 |
       2048 |     955,99 |    170,52 |     956,46 |    952,86 |
       3072 |     956,00 |     51,97 |     956,46 |    952,85 |

2. Filtering based on UDP protocol's source port, for example:
   $fwcmd -A $MAIN -p udp --source-port 1    -j DROP
   ...
   $fwcmd -A $MAIN -p udp --source-port 1024 -j DROP
   $fwcmd -A $MAIN -p udp                    -j ACCEPT

  Results:
  rules     | plain NF               | NF-HIPAC
            | sent       | got thru  | sent       | got thru  |
      (n.o) |   (Mbit/s) |  (Mbit/s) |   (Mbit/s) |  (Mbit/s) |
  -------------------------------------------------------------
          0 |     955,37 |    954,33 |     956,46 |    952,85 |
        512 |     980,68 |    261,41 |     956,46 |    951,92 |
       1024 |        N/A |       N/A |     956,47 |    952,86 |
       2048 |        N/A |       N/A |     956,46 |    952,85 |
       3072 |        N/A |       N/A |     956,46 |    952,85 |

N/A = Netfilter bridging can't handle this at all, no traffic can pass the
bridge.

So, plain Netfilter can tolerate about a couple of hundred rules 
checking for addresses and/or ports on a gigabit line.

With HIPAC Netfilter, packet loss is very low, less than 0.5%, even with the
maximum number (of tested) rules, the same amount as without filtering at
all.


On Sun, 29 Jun 2003, Michael Bellion and Thomas Heinz wrote:
> You wrote:
> >>We are going to test the stuff tomorrow on an i386 and tell you
> >>the results afterwards.
> 
> Well, nf-hipac works fine together with the ebtables patch for 2.4.21
> on an i386 machine. We expect it to work with other patches too.
> 
> >>In principle, nf-hipac should work properly whith the bridge patch.
> >>We expect it to work just like iptables apart from the fact that
> >>you cannot match on bridge ports.
> 
> Well, this statement holds for the native nf-hipac in/out interface
> match but of course you can match on bridge ports with nf-hipac
> using the iptables physdev match. So everything should be fine :)
> 
> > One obvious thing that's missing in your performance and Roberto's figures 
> > is what *exactly* are the non-matching rules.  Ie. do they only match IP 
> > address, a TCP port, or what? (TCP port matching is about a degree of 
> > complexity more expensive with iptables, I recall.)
> 
> [answered in private e-mail]
> 
> 
> Regards,
> 
> +-----------------------+----------------------+
> |   Michael Bellion     |     Thomas Heinz     |
> | <mbellion@hipac.org>  |  <creatix@hipac.org> |
> +-----------------------+----------------------+
> 
> 

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
