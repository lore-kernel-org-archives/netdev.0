From: Kouya Shimura <kouya@jp.fujitsu.com>
Subject: ipv4: ip unreachable with SO_BINDTODEVICE socket
Date: Wed, 11 Nov 2015 14:49:57 +0900
Message-ID: <87egfxjd9o.fsf@pingu.sky.yk.fujitsu.co.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Ow9++P3ZC7"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Ow9++P3ZC7
Content-Type: text/plain; charset="us-ascii"
Content-Description: message body text
Content-Transfer-Encoding: 7bit

Hi

When both server and client are on the same machine and each their
socket option is set to SO_BINDTODEVICE, sometimes a packet doesn't
reach to the server.

The reproducible test program is attached. (modify "IF_ADDR=, IP_ADDR=,
PORT=" lines appropriately).  Please try 'taskset -c 1 python test.py'
since per cpu data (rt_cache) affects results.  Also 'tcpdump -i lo'
is helpful for testing.  you can see "ICMP udp port unreachable".

In this test program, a packet doesn't pass through the bound
interface but 'lo' interface. So, it might be granted that local
communication with SO_BINDTODEVICE socket fails. However, dnsmasq and
dhcp_release commands rely on it (Actually I've found this issue on
the OpenStack envirionment) and the test program works well on
linux-2.6.32 but doesn't work on linux-3.10.0 and 4.3.0.

I'd like to know whether this is a kernel bug or the specification of
SO_BINDTODEVICE.

The attached patch fixes this issue, but no confidence this is a
right modification.

Thanks,
Kouya


--Ow9++P3ZC7
Content-Type: text/plain
Content-Disposition: inline; filename="test.py"
Content-Transfer-Encoding: 7bit

#!/usr/bin/env python2
import sys,socket,time,threading

IF_DEVICE="eth0"
IP_ADDR="10.0.2.15"
PORT=13531

try:
    SO_BINDTODEVICE=socket.SO_BINDTODEVICE
except:
    SO_BINDTODEVICE=25

class Server(threading.Thread):
    def __init__(self, dev, port):
        threading.Thread.__init__(self)
        self.sk = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        if dev:
            self.sk.setsockopt(socket.SOL_SOCKET, SO_BINDTODEVICE, dev)
        self.sk.bind(('', port))

    def run(self):
        while True:
            (data, addr) = self.sk.recvfrom(1024)
            print(("recv:%s from %s" % (data, str(addr))))
            if data == 'finish':
                break

# flush rt_cache.
def flush_rt_cache():
    f = open('/proc/sys/net/ipv4/route/flush', 'w')
    f.write('flush') # any message is ok.
    f.close()

# create a rt_cache which is not bound to dev.
# send a dummy packet to ssh port. (any port is ok)
def create_dummy_rt_cache():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((IP_ADDR, 22))
    s.send('dummy')
    s.close()

def connect_and_send(msg):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.setsockopt(socket.SOL_SOCKET, SO_BINDTODEVICE, IF_DEVICE)
    s.connect((IP_ADDR, PORT))
    s.send(msg)
    
if __name__ == '__main__':
    flush_rt_cache()
    create_dummy_rt_cache()
    # start a server thread.
    server = Server(IF_DEVICE, PORT)
    server.start()
    # start clients. but never connect to the server.
    for count in range(10):
        time.sleep(1)
        connect_and_send("count=%d" % count)
        print(("sent:count=%s" % count))
    # revive the connection.
    flush_rt_cache()
    # now, successfully connect to the server.
    connect_and_send('finish')
    server.join()


--Ow9++P3ZC7
Content-Type: text/plain
Content-Disposition: inline;
	filename="0001-PATCH-net-ipv4-re-create-rt_dst-when-rt_iif-doesn-t-.patch"
Content-Transfer-Encoding: 7bit

From: Kouya Shimura <kouya@jp.fujitsu.com>
Date: Tue, 10 Nov 2015 17:15:26 +0900
Subject: [PATCH net] ipv4: re-create rt_dst when rt_iif doesn't match orig_oif

Otherwise packets sometimes unreach when the socket is bind to a device.

Signed-off-by: Kouya Shimura <kouya@jp.fujitsu.com>
---
 net/ipv4/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 85f184e..546cabe 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2027,7 +2027,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 			prth = raw_cpu_ptr(nh->nh_pcpu_rth_output);
 		}
 		rth = rcu_dereference(*prth);
-		if (rt_cache_valid(rth)) {
+		if (rt_cache_valid(rth) && rth->rt_iif == orig_oif) {
 			dst_hold(&rth->dst);
 			return rth;
 		}
-- 
1.9.1


--Ow9++P3ZC7--
