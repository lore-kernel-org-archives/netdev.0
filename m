From: Steve Hill <steve@services.navaho.net>
Subject: IPSEC
Date: Tue, 8 Mar 2005 17:25:10 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0503081706560.11525@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This might not be the right place for me to post (is there a better place 
to ask about ipsec problems using the 2.6 kernel's built in IPSEC 
support?).  Anyway, I'm hoping someone can help here:

I'm trying to connect 2 boxes together in transport mode using PSKs with 
Racoon (I'll migrate to X.509 certs and tunnel mode once I've got this 
working).  I'm on the 2.6.10 Fedora Core 3 kernel with Racoon 0.5 and I'm 
running in AH and ESP mode.  When the 2 machines set up the SAs with 
eachother, Racoon thinks everything's ok and logs that the ESP and AH 
sessions are established in both directions, however on one of the 
machines the SAD only contains 3 entries:

(this is setkey -D dumped from the machine with IP address "a.b.c.d"):

   a.b.c.d w.x.y.z
         esp mode=transport spi=230360363(0x0dbb052b) reqid=0(0x00000000)
         E: 3des-cbc  c3f07995 d878c486 55b181ee 15aa670d a4b96fc1 d4099a9c
         A: hmac-sha1  0533aed9 4591125c 6ae8e740 51f3b066 fc5222fc
         seq=0x00000000 replay=4 flags=0x00000000 state=mature
         created: Mar  8 17:05:19 2005   current: Mar  8 17:05:21 2005
         diff: 2(s)      hard: 3600(s)   soft: 2880(s)
         last:                           hard: 0(s)      soft: 0(s)
         current: 0(bytes)       hard: 0(bytes)  soft: 0(bytes)
         allocated: 0    hard: 0 soft: 0
         sadb_seq=2 pid=3704 refcnt=0
   w.x.y.z a.b.c.d
         esp mode=transport spi=261919355(0x0f9c927b) reqid=0(0x00000000)
         E: 3des-cbc  b1051e37 4482da28 adc8aee8 92046dda 2c5e3dc1 11e62536
         A: hmac-sha1  ea69668e 42cbca96 22b0d941 6bfa5f2d bb39be74
         seq=0x00000000 replay=4 flags=0x00000000 state=mature
         created: Mar  8 17:05:19 2005   current: Mar  8 17:05:21 2005
         diff: 2(s)      hard: 3600(s)   soft: 2880(s)
         last:                           hard: 0(s)      soft: 0(s)
         current: 0(bytes)       hard: 0(bytes)  soft: 0(bytes)
         allocated: 0    hard: 0 soft: 0
         sadb_seq=1 pid=3704 refcnt=0
   w.x.y.z a.b.c.d
         ah mode=transport spi=2363330(0x00240fc2) reqid=0(0x00000000)
         A: hmac-sha1  702e8bf2 1aa44422 0f46ae1d b213d871 4fc6c57b
         seq=0x00000000 replay=4 flags=0x00000000 state=mature
         created: Mar  8 17:05:19 2005   current: Mar  8 17:05:21 2005
         diff: 2(s)      hard: 3600(s)   soft: 2880(s)
         last:                           hard: 0(s)      soft: 0(s)
         current: 0(bytes)       hard: 0(bytes)  soft: 0(bytes)
         allocated: 0    hard: 0 soft: 0
         sadb_seq=0 pid=3704 refcnt=0

As you can see, the outbound AH SA isn't in the SAD even though Racoon 
claims it's all fine.  Since this is reliably reproduced I have done some 
debugging on the kernel side but I've ended up rather confused.

During the negotiation, xfrm_state_add is successfully called for both 
outbound SAs.  I added some printk() statements to see what it was doing 
and ended up with:

   xfrm_state_add: Called with seq: 00e74298, Family: 2, seq 1, proto 51
   __xfrm_find_acq_byseq: Returned NULL
   __xfrm_state_insert: Called with seq: 00e74298
   xfrm_state_add: Called with seq: 0dbb052b, Family: 2, seq 1, proto 50
   __xfrm_find_acq_byseq: Returned 00e74298
   __xfrm_state_insert: Called with seq: 0dbb052b
   xfrm_state_delete: Called with seq: 00e74298

>From this logging it seems the AH SA has been added to the SAD ok, but 
then the ESP SA is added and it has the same sequence number (1) as the AH 
SA so the AH SA gets deleted.

The xfrm_state_add() function does:
         x1 = __xfrm_find_acq_byseq(x->km.seq);
         ...
         xfrm_state_delete(x1);
And this is responsible for deleting the AH SA due to it's matching 
sequence number.

I'm not sure what's at fault here - what generates the sequence number?  I 
presume from the checking that's done here that the sequence number is 
always expected to be unique, so it seems that either a unique sequence 
number is never being generated or Racoon is plain not using it.  (Correct 
me if I'm wrong here).

Any help would be appreciated - I've been battling with this problem for 
several days.  Thanks.

- Steve Hill (BSc)
Senior Software Developer                        Email: steve@navaho.co.uk
Navaho Technologies Ltd.                           Tel: +44-870-7034015
