From: "David S. Miller" <davem@redhat.com>
Subject: Re: mtu_expires variable
Date: Sun, 18 May 2003 18:32:14 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030518.183214.08324647.davem@redhat.com>
References: <Pine.GSO.4.10.10305162243050.13822-100000@tigre.dcc.unicamp.br>
	<20030518174024.014cb734.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: massia@ic.unicamp.br, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: rddunlap@osdl.org
In-Reply-To: <20030518174024.014cb734.rddunlap@osdl.org>
List-Id: netdev.vger.kernel.org

   From: "Randy.Dunlap" <rddunlap@osdl.org>
   Date: Sun, 18 May 2003 17:40:24 -0700

   On Fri, 16 May 2003 23:16:03 -0300 (EST) Felipe Massia Pereira <massia@ic.unicamp.br> wrote:   [on LKML]
   
   | I've came accross this var because we want to do some experiments in class
   | with Path MTU discovery.  But it happens that MTU is recorded between
   | experiments (and it's what we expect: that the stack does not do a PMTU
   | every time). BTW where is the PMTU value kept? Is MTU value recorded for
   | each destination or for each route?
   | 
   | So it would be nice if we could make the value found in a experiment to be
   | forgotten by the kernel so the students could execute the ping several
   | times. (ping -c 2 -m want ...) Is mtu_expires what we're looking for?
   
   Maybe someone else can answer this...
   
PMTU is stored at routing cache entries (inside of the dst_entry part
of the rtable).  If routing cache entry is flushed, this information
is forgotten.  Also, PMTUs are expired periodically, and this is
controlled by calling dst_set_expires() which expires the entry
at ip_rt_mtu_expires jiffies into the future.

You can use a hammer to force all PMTU information to be forgotten
by flushing entire routing cache, this is done via:

echo "0" >/proc/sys/net/ipv4/route/flush

   | We tried to "echo 1 > /proc/sys/net/ipv4/route/mtu_expires" considering
   | that it's expressed in seconds. The usual value is 600. But I've read that
   | it's expressed in jiffies. Jiffies occur 100 times per sec on a PC, is it?
   | So the value 600 on a PC means 6 seconds?
   
   In 2.4.x there are 100 jiffies / second on a PC (x86 arch).
   However, /proc/sys/net/ipv4/route/mtu_expires is hiding this HZ
   conversion factor from us, so that the value is expressed in seconds
   and not in jiffies, so 600 is 600 seconds = 10 minutes.
   
This is correct, the user's value is converted into jiffies and
stored into ip_rt_mtu_expires.

BUT!  This only takes effect for NEW pmtu information gathered.
It does not apply to existing ones.  Best idea is to flush the
routing cache after such a change.
