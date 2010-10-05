From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Tue, 5 Oct 2010 16:10:00 +0530
Message-ID: <OF13594229.1A55A20C-ON652577B3.00393C8D-652577B3.003A54C9@in.ibm.com>
References: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com> <20100919124443.GJ7350@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, kvm@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:34673 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226Ab0JEKhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 06:37:25 -0400
In-Reply-To: <20100919124443.GJ7350@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 09/19/2010 06:14:43 PM:

> Could you document how exactly do you measure multistream bandwidth:
> netperf flags, etc?

All results were without any netperf flags or system tuning:
    for i in $list
    do
        netperf -c -C -l 60 -H 192.168.122.1 > /tmp/netperf.$$.$i &
    done
    wait
Another script processes the result files.  It also displays the
start time/end time of each iteration to make sure skew due to
parallel netperfs is minimal.

I changed the vhost functionality once more to try to get the
best model, the new model being:
1. #numtxqs=1 -> #vhosts=1, this thread handles both RX/TX.
2. #numtxqs>1 -> vhost[0] handles RX and vhost[1-MAX] handles
   TX[0-n], where MAX is 4.  Beyond numtxqs=4, the remaining TX
   queues are handled by vhost threads in round-robin fashion.

Results from here on are with these changes, and only "tuning" is
to set each vhost's affinity to CPUs[0-3] ("taskset -p f <vhost-pids>").

> Any idea where does this come from?
> Do you see more TX interrupts? RX interrupts? Exits?
> Do interrupts bounce more between guest CPUs?
> 4. Identify reasons for single netperf BW regression.

After testing various combinations of #txqs, #vhosts, #netperf
sessions, I think the drop for 1 stream is due to TX and RX for
a flow being processed on different cpus.  I did two more tests:
    1. Pin vhosts to same CPU:
        - BW drop is much lower for 1 stream case (- 5 to -8% range)
        - But performance is not so high for more sessions.
    2. Changed vhost to be single threaded:
          - No degradation for 1 session, and improvement for upto
	      8, sometimes 16 streams (5-12%).
          - BW degrades after that, all the way till 128 netperf sessions.
          - But overall CPU utilization improves.
            Summary of the entire run (for 1-128 sessions):
                txq=4:  BW: (-2.3)      CPU: (-16.5)    RCPU: (-5.3)
                txq=16: BW: (-1.9)      CPU: (-24.9)    RCPU: (-9.6)

I don't see any reasons mentioned above.  However, for higher
number of netperf sessions, I see a big increase in retransmissions:
_______________________________________
#netperf      ORG           NEW
            BW (#retr)    BW (#retr)
_______________________________________
1          70244 (0)     64102 (0)
4          21421 (0)     36570 (416)
8          21746 (0)     38604 (148)
16         21783 (0)     40632 (464)
32         22677 (0)     37163 (1053)
64         23648 (4)     36449 (2197)
128        23251 (2)     31676 (3185)
_______________________________________

Single netperf case didn't have any retransmissions so that is not
the cause for drop.  I tested ixgbe (MQ):
___________________________________________________________
#netperf      ixgbe             ixgbe (pin intrs to cpu#0 on
                                       both server/client)
            BW (#retr)          BW (#retr)
___________________________________________________________
1           3567 (117)          6000 (251)
2           4406 (477)          6298 (725)
4           6119 (1085)         7208 (3387)
8           6595 (4276)         7381 (15296)
16          6651 (11651)        6856 (30394)
___________________________________________________________

> 5. Test perf in more scenarious:
>    small packets

512 byte packets - BW drop for upto 8 (sometimes 16) netperf sessions,
but increases with #sessions:
_______________________________________________________________________________
#       BW1     BW2 (%)         CPU1    CPU2 (%)        RCPU1   RCPU2 (%)
_______________________________________________________________________________
1       4043    3800 (-6.0)     50      50 (0)          86      98 (13.9)
2       8358    7485 (-10.4)    153     178 (16.3)      230     264 (14.7)
4       20664   13567 (-34.3)   448     490 (9.3)       530     624 (17.7)
8       25198   17590 (-30.1)   967     1021 (5.5)      1085    1257 (15.8)
16      23791   24057 (1.1)     1904    2220 (16.5)     2156    2578 (19.5)
24      23055   26378 (14.4)    2807    3378 (20.3)     3225    3901 (20.9)
32      22873   27116 (18.5)    3748    4525 (20.7)     4307    5239 (21.6)
40      22876   29106 (27.2)    4705    5717 (21.5)     5388    6591 (22.3)
48      23099   31352 (35.7)    5642    6986 (23.8)     6475    8085 (24.8)
64      22645   30563 (34.9)    7527    9027 (19.9)     8619    10656 (23.6)
80      22497   31922 (41.8)    9375    11390 (21.4)    10736   13485 (25.6)
96      22509   32718 (45.3)    11271   13710 (21.6)    12927   16269 (25.8)
128     22255   32397 (45.5)    15036   18093 (20.3)    17144   21608 (26.0)
_______________________________________________________________________________
SUM:    BW: (16.7)      CPU: (20.6)     RCPU: (24.3)
_______________________________________________________________________________

> host -> guest
_______________________________________________________________________________
#       BW1     BW2 (%)         CPU1    CPU2 (%)        RCPU1   RCPU2 (%)
_______________________________________________________________________________
*1      70706   90398 (27.8)    300     327 (9.0)       140     175 (25.0)
2       20951   21937 (4.7)     188     196 (4.2)       93      103 (10.7)
4       19952   25281 (26.7)    397     496 (24.9)      210     304 (44.7)
8       18559   24992 (34.6)    802     1010 (25.9)     439     659 (50.1)
16      18882   25608 (35.6)    1642    2082 (26.7)     953     1454 (52.5)
24      19012   26955 (41.7)    2465    3153 (27.9)     1452    2254 (55.2)
32      19846   26894 (35.5)    3278    4238 (29.2)     1914    3081 (60.9)
40      19704   27034 (37.2)    4104    5303 (29.2)     2409    3866 (60.4)
48      19721   26832 (36.0)    4924    6418 (30.3)     2898    4701 (62.2)
64      19650   26849 (36.6)    6595    8611 (30.5)     3975    6433 (61.8)
80      19432   26823 (38.0)    8244    10817 (31.2)    4985    8165 (63.7)
96      20347   27886 (37.0)    9913    13017 (31.3)    5982    9860 (64.8)
128     19108   27715 (45.0)    13254   17546 (32.3)    8153    13589 (66.6)
_______________________________________________________________________________
SUM:    BW: (32.4)      CPU: (30.4)     RCPU: (62.6)
_______________________________________________________________________________
*: Sum over 7 iterations, remaining test cases are sum over 2 iterations

> guest <-> external

I haven't done this right now since I don't have a setup.  I guess
it would be limited by wire speed and gains may not be there.  I
will try to do this later when I get the setup.

> in last case:
> find some other way to measure host CPU utilization,
> try multiqueue and single queue devices
> 6. Use above to figure out what is a sane default for numtxqs

A. Summary for default I/O (16K):
#txqs=2 (#vhost=3):       BW: (37.6)      CPU: (69.2)     RCPU: (40.8)
#txqs=4 (#vhost=5):       BW: (36.9)      CPU: (60.9)     RCPU: (25.2)
#txqs=8 (#vhost=5):       BW: (41.8)      CPU: (50.0)     RCPU: (15.2)
#txqs=16 (#vhost=5):      BW: (40.4)      CPU: (49.9)     RCPU: (10.0)

B. Summary for 512 byte I/O:
#txqs=2 (#vhost=3):       BW: (31.6)      CPU: (35.7)     RCPU: (28.6)
#txqs=4 (#vhost=5):       BW: (5.7)       CPU: (27.2)     RCPU: (22.7)
#txqs=8 (#vhost=5):       BW: (-.6)       CPU: (25.1)     RCPU: (22.5)
#txqs=16 (#vhost=5):      BW: (-6.6)      CPU: (24.7)     RCPU: (21.7)

Summary:

1. Average BW increase for regular I/O is best for #txq=16 with the
   least CPU utilization increase.
2. The average BW for 512 byte I/O is best for lower #txq=2. For higher
   #txqs, BW increased only after a particular #netperf sessions - in
   my testing that limit was 32 netperf sessions.
3. Multiple txq for guest by itself doesn't seem to have any issues.
   Guest CPU% increase is slightly higher than BW improvement.  I
   think it is true for all mq drivers since more paths run in parallel
   upto the device instead of sleeping and allowing one thread to send
   all packets via qdisc_restart.
4. Having high number of txqs gives better gains and reduces cpu util
   on the guest and the host.
5. MQ is intended for server loads.  MQ should probably not be explicitly
   specified for client systems.
6. No regression with numtxqs=1 (or if mq option is not used) in any
   testing scenario.

I will send the v3 patch within a day after some more testing.

Thanks,

- KK

