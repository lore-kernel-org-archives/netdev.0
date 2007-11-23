From: Joerg Pommnitz <pommnitz@yahoo.com>
Subject: Does tc-prio really work as advertised?
Date: Fri, 23 Nov 2007 06:47:13 -0800 (PST)
Message-ID: <292416.28036.qm@web51406.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: OLSR discussion and development <olsr-users@olsr.org>
To: netdev@vger.kernel.org
Return-path: <olsr-users-bounces@lists.olsr.org>
List-Unsubscribe: <http://lists.olsr.org/mailman/listinfo/olsr-users>,
	<mailto:olsr-users-request@lists.olsr.org?subject=unsubscribe>
List-Archive: <http://lists.olsr.org/pipermail/olsr-users>
List-Post: <mailto:olsr-users@lists.olsr.org>
List-Help: <mailto:olsr-users-request@lists.olsr.org?subject=help>
List-Subscribe: <http://lists.olsr.org/mailman/listinfo/olsr-users>,
	<mailto:olsr-users-request@lists.olsr.org?subject=subscribe>
Sender: olsr-users-bounces@lists.olsr.org
Errors-To: olsr-users-bounces@lists.olsr.org
List-Id: netdev.vger.kernel.org

Hello all,
I might make a fool out of me, but I think the prio qdisc doesn't work as advertised in any document I could lay my hands on.

My problem was that the link quality reported by the olsr.org olsrd degraded depending on the amount of payload traffic transferred through an adhoc/mesh interface. The LQ is calculated from the packet loss of LQ Hello packets sent through this interface. To make sure normal traffic does not interfere with this value, olsrd sets the TOS field to 0x10 (Minimize-Delay) by default. This should give olsr traffic the highest priority on the link.

Investigating this issue I replaced the default Pfifo_fast with a prio qdisc and attached a pfifo on each of the bands:

    INTERFACE=wifi0
    tc qdisc add dev $INTERFACE root handle 1: prio
    tc qdisc add dev $INTERFACE parent 1:1 handle 10: pfifo
    tc qdisc add dev $INTERFACE parent 1:2 handle 20: pfifo
    tc qdisc add dev $INTERFACE parent 1:3 handle 30: pfifo

The I used ping -Q TOSVALUE to send packets with different TOS values through the interface. tcpdump confirmed the correct TOS values in the outgoing packets.

With "tc -s qdisc ls dev wifi0" I could observe the effects of the different TOS values. The result: no effect at all! Every single packet used the band indicated by the first value in the priomap (e.g. band 1 by default, in my case the pfifo with handle 20:). I can't square this observation with the available documentation.

Looking at the source code, it seems that sched_prio uses the skb->priority value to select the outgoing band. According to some documentation I found, an application can set this value.

Now I'm at a loss. I can work around this problem with filters, but I don't think that this is the correct solution. Any suggestions?

 






      Heute schon einen Blick in die Zukunft von E-Mails wagen? www.yahoo.de/mail

-- 
Olsr-users mailing list
Olsr-users@lists.olsr.org
http://lists.olsr.org/mailman/listinfo/olsr-users
