From: Patrick McManus <mcmanus@ducksong.com>
Subject: 2.6.27 problem with shaping using netem/ifb (regression?)
Date: Wed, 01 Oct 2008 19:04:45 -0400
Message-ID: <1222902286.6395.22.camel@tng>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-DHwji5QY5P7ZPkYjQuw2"
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:46398 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbYJAXNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 19:13:16 -0400
Received: from [192.168.16.214] (cpe-76-179-219-229.maine.res.rr.com [76.179.219.229])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by linode.ducksong.com (Postfix) with ESMTP id 88BB01009A
	for <netdev@vger.kernel.org>; Wed,  1 Oct 2008 19:04:49 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DHwji5QY5P7ZPkYjQuw2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi all,

I have a set of scripts I use to emulate certain network conditions on
localhost. (i.e. change the latency, bandwidth, etc..). they use netem
and ifb along with tc and ip to get the job done - they are used to
measure and evaluate changes to userspace applications under a variety
of cell-phone-like network conditions.

It has worked well on 23, 24, 25, and 26.. 

Using the pre-27 kernel in Ubuntu's ibex beta the scripts are pretty
broken. I built a kernel from git (up to date with today) and indeed,
they are broken under that too.

I've distilled the whole thing into a python script, attached, which
sets up the network (160 kbit/s, 750ms latency), starts a python
webserver and then launches wget (which pulls from that server on port
8912) to see how fast it goes.. when it is working I see ~19KB/s of
goodput but on .27 it typically just limps along at less than 1 KB/sec.

I've tried to bisect it, but various interim .27 builds throw OOPS at
the tc commands used in the script (qdisc_create).. hard to narrow
anything down there. The current tip doesn't OOPS, but it doesn't behave
as expected either. I'm happy to try a particular tag if suggested. 

Any thoughts on where to look? I hope attaching the script is helpful -
it is pretty self evident when running it if things are working ok. This
is all on amd64 if that is relevant.

-Patrick

--=-DHwji5QY5P7ZPkYjQuw2
Content-Disposition: attachment; filename="shaping-test.py"
Content-Type: text/x-python; name="shaping-test.py"; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

# port is 8912

wget = "wget"

modprobe = "/sbin/modprobe"
tc  = "/sbin/tc"
ip  = "/sbin/ip"

# Some things we can configure
bw =  160.0
bwu = "kbit"
upbw = 54.0
upbwu = "kbit"


# delay, loss, jitter is bidi - so 770 rtt
delayms = 385
loss = .015
jitterms = 50.0
reorderx = .1

# Our python support libraries
import os
import sys
import time
from BaseHTTPServer import HTTPServer
from SocketServer import ThreadingMixIn
import SimpleHTTPServer
import threading

if os.getuid() != 0:
 print "Must run as root to manipulate kernel shaping policies"
 sys.exit(1)

try:
 os.stat (modprobe)
 os.stat (tc)
 os.stat (ip)

except OSError, e:
 print "Required Utility Not Found: " + e.filename 
 sys.exit(1)

if os.system (modprobe + " sch_netem") != 0:
 print "Module sch_metem required"
 sys.exit(1)

if  os.system (modprobe + " ifb") != 0:
 print "Module ifb required"
 sys.exit(1)

# This is the cleanup function - makes sure the network is nice and tidy.
# Run it when we start, run it when we quit.. run it on error - try hard to
# leave things sane

def scrub():
    try:
        # some basic hygeine :: clean slate
        os.system (ip + " link set dev ifb0 down   2> /dev/null")
        os.system (ip + " link set dev ifb1 down   2> /dev/null")
        os.system (tc + " qdisc del dev lo root    2> /dev/null")
        os.system (tc + " qdisc del dev ifb0 root  2> /dev/null  ")
        os.system (tc + " qdisc del dev ifb1 root  2> /dev/null ")
        os.system (tc + " qdisc del dev lo ingress 2> /dev/null")
    except:
        pass

    try:
        w3.runok = 0
    except:
        pass

class shaperError(Exception):
    def __init__(self,  message):
        self.message = message

# silently serve up uncachable files on localhost
class quietHTTPServer(SimpleHTTPServer.SimpleHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    
    def __init__ (self, ip, port, handler):
        SimpleHTTPServer.SimpleHTTPRequestHandler.__init__ (self, ip,  port, handler)
    
    def log_request(self, code): 
        pass
    def log_error(self, format, *args):
        pass
    def send_response(self, code, message=None):
        SimpleHTTPServer.SimpleHTTPRequestHandler.send_response(self, code ,message)
        self.send_header ("Cache-Control", "no-cache")

    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Length", 500000)
        self.end_headers()
        for i in range (0, 50000):
            self.wfile.write ("0123456789")

# This is the internal webserver - it runs only on localhost

class myhttp(ThreadingMixIn, HTTPServer):
    pass
    def __init__ (self, one, two):
        self.request_queue_size = 20
        HTTPServer.__init__ (self,one,two)

class W3Thread ( threading.Thread ):
     def run ( self ):
         server = myhttp (('127.0.0.1', 8912), quietHTTPServer)
         # this hack will check every 1 seconds to see if we ought to exit this thread
         self.runok = 1
         server.socket.settimeout(1)
         server.daemon_threads = True
         while self.runok != 0:
             server.handle_request()

# Main()
try:
    lossstr = "loss " + str(loss) +"% "	
    delaystr = " delay " + str (delayms) + "ms "
#    delaystr += str (jitterms) + "ms distribution pareto"
    reorderstr = " reorder " + str (reorderx) + "% 30%"

    # scrub the network to make sure we are in a good state
    scrub()

    # Setup the shaping environment

    os.system (ip + " link set dev lo mtu 1500")
    os.system (tc + " qdisc add dev lo ingress")
    os.system (ip + " link set dev ifb0 up 2> /dev/null")
    os.system (ip + " link set dev ifb1 up 2> /dev/null")

    # 0x22d0 is port 8912

    # ifb0 is http request and ack path (uplink)
    os.system (tc + " filter add dev lo protocol ip root prio 10 u32 match u32 0x000022d0 0x0000ffff at 20 flowid 5:1 action mirred egress redirect dev ifb0 > /dev/null")
    os.system (tc + " qdisc add dev ifb0 root handle 2: netem " + lossstr + delaystr + reorderstr)
    os.system (tc + " qdisc add dev ifb0 parent 2:1 handle 3: tbf rate " + str (upbw) + upbwu + " latency 3s burst 12kb")
    os.system (tc + " qdisc add dev ifb0 parent 3:1 pfifo limit 1500")

    # ifb1 is http server and data response (downlink)
    os.system (tc + " filter add dev lo protocol ip root prio 10 u32 match u32 0x22d00000 0xffff0000 at 20 flowid 5:2 action mirred egress redirect dev ifb1 > /dev/null")
    os.system (tc + " qdisc add dev ifb1 root handle 2: netem " + lossstr + delaystr + reorderstr)
    os.system (tc + " qdisc add dev ifb1 parent 2:1 handle 3: tbf rate " + str (bw) + bwu + " latency 3s burst 12kb")
    os.system (tc + " qdisc add dev ifb1 parent 3:1 pfifo limit 1500")
        
    # default rule through ifb1 both ways to catch no port 8912 traffic (dns, etc..) with at least a basic estimate
    os.system (tc + " filter add dev lo protocol ip root prio 20 u32 match u32 0 0 at 20 flowid 5:3 action mirred egress redirect dev ifb1 > /dev/null")

    # start up the localhost webserver
    w3 = W3Thread()
    w3.start()

    os.system (wget + " -O /dev/null http://localhost:8912/foo")

    
except shaperError, e:
    print "ERROR: " + e.message

except:
    print "raising general exception, but cleaning up interfaces first"
    scrub()
    raise


# do a good cleanup on normal exit - we're all done and the results are on stdout
scrub()


--=-DHwji5QY5P7ZPkYjQuw2--

