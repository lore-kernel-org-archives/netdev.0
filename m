From: Josef Bacik <jbacik@fb.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Thu, 15 Dec 2016 13:53:36 -0500
Message-ID: <1481828016.24490.5@smtp.office365.com>
References: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
        <1481231024.1911284.813071977.72AF4DEE@webmail.messagingengine.com>
        <1481233016.11849.1@smtp.office365.com>
        <1481243432.4930.145.camel@edumazet-glaptop3.roam.corp.google.com>
        <6C6EE0ED-7E78-4866-8AAF-D75FD4719EF3@fb.com>
        <1481335192.3663.0@smtp.office365.com>
        <1481341624.4930.204.camel@edumazet-glaptop3.roam.corp.google.com>
        <1481343298.4930.208.camel@edumazet-glaptop3.roam.corp.google.com>
        <1481565929.24490.0@smtp.office365.com>
        <3c022731-e703-34ac-55f1-60f5b94b6d62@stressinduktion.org>
        <1481581466.24490.2@smtp.office365.com>
        <CALx6S34S82kFVqYW1M0ZuHx_Mxut4QaLFVerLX4aEsksrFirXg@mail.gmail.com>
        <CAEfhGiyFW1YHmmUYpFv+q4J4r=wSv3ZBZowG69BqkT3p-G4gNw@mail.gmail.com>
        <CALx6S369T_hvoTgyHbmeSiR2p3d68h+0tMKqMmcGYLrKiN3JMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-lkL1riTTK+BdyXvO4gxS"
Cc: Craig Gallek <kraigatgoog@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "Linux Kernel Network Developers" <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58260 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753369AbcLOSxx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 13:53:53 -0500
In-Reply-To: <CALx6S369T_hvoTgyHbmeSiR2p3d68h+0tMKqMmcGYLrKiN3JMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-lkL1riTTK+BdyXvO4gxS
Content-Type: text/plain; charset="utf-8"; format=flowed

On Tue, Dec 13, 2016 at 6:32 PM, Tom Herbert <tom@herbertland.com> 
wrote:
> On Tue, Dec 13, 2016 at 3:03 PM, Craig Gallek <kraigatgoog@gmail.com> 
> wrote:
>>  On Tue, Dec 13, 2016 at 3:51 PM, Tom Herbert <tom@herbertland.com> 
>> wrote:
>>>  I think there may be some suspicious code in inet_csk_get_port. At
>>>  tb_found there is:
>>> 
>>>                  if (((tb->fastreuse > 0 && reuse) ||
>>>                       (tb->fastreuseport > 0 &&
>>>                        !rcu_access_pointer(sk->sk_reuseport_cb) &&
>>>                        sk->sk_reuseport && uid_eq(tb->fastuid, 
>>> uid))) &&
>>>                      smallest_size == -1)
>>>                          goto success;
>>>                  if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, 
>>> tb, true)) {
>>>                          if ((reuse ||
>>>                               (tb->fastreuseport > 0 &&
>>>                                sk->sk_reuseport &&
>>>                                
>>> !rcu_access_pointer(sk->sk_reuseport_cb) &&
>>>                                uid_eq(tb->fastuid, uid))) &&
>>>                              smallest_size != -1 && --attempts >= 
>>> 0) {
>>>                                  spin_unlock_bh(&head->lock);
>>>                                  goto again;
>>>                          }
>>>                          goto fail_unlock;
>>>                  }
>>> 
>>>  AFAICT there is redundancy in these two conditionals.  The same 
>>> clause
>>>  is being checked in both: (tb->fastreuseport > 0 &&
>>>  !rcu_access_pointer(sk->sk_reuseport_cb) && sk->sk_reuseport &&
>>>  uid_eq(tb->fastuid, uid))) && smallest_size == -1. If this is true 
>>> the
>>>  first conditional should be hit, goto done,  and the second will 
>>> never
>>>  evaluate that part to true-- unless the sk is changed (do we need
>>>  READ_ONCE for sk->sk_reuseport_cb?).
>>  That's an interesting point... It looks like this function also
>>  changed in 4.6 from using a single local_bh_disable() at the 
>> beginning
>>  with several spin_lock(&head->lock) to exclusively
>>  spin_lock_bh(&head->lock) at each locking point.  Perhaps the full 
>> bh
>>  disable variant was preventing the timers in your stack trace from
>>  running interleaved with this function before?
> 
> Could be, although dropping the lock shouldn't be able to affect the
> search state. TBH, I'm a little lost in reading function, the
> SO_REUSEPORT handling is pretty complicated. For instance,
> rcu_access_pointer(sk->sk_reuseport_cb) is checked three times in that
> function and also in every call to inet_csk_bind_conflict. I wonder if
> we can simply this under the assumption that SO_REUSEPORT is only
> allowed if the port number (snum) is explicitly specified.

Ok first I have data for you Hannes, here's the time distributions 
before during and after the lockup (with all the debugging in place the 
box eventually recovers).  I've attached it as a text file since it is 
long.

Second is I was thinking about why we would spend so much time doing 
the ->owners list, and obviously it's because of the massive amount of 
timewait sockets on the owners list.  I wrote the following dumb patch 
and tested it and the problem has disappeared completely.  Now I don't 
know if this is right at all, but I thought it was weird we weren't 
copying the soreuseport option from the original socket onto the twsk.  
Is there are reason we aren't doing this currently?  Does this help 
explain what is happening?  Thanks,

Josef

--=-lkL1riTTK+BdyXvO4gxS
Content-Type: multipart/mixed; boundary="=-PS77I0BnswqhqXDRakTH"

--=-PS77I0BnswqhqXDRakTH
Content-Type: text/plain
Content-Disposition: attachment; filename="timing-dist.txt"

     inet_csk_get_port   : count     distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 0        |                                        |
        32 -> 63         : 0        |                                        |
        64 -> 127        : 0        |                                        |
       128 -> 255        : 0        |                                        |
       256 -> 511        : 0        |                                        |
       512 -> 1023       : 0        |                                        |
      1024 -> 2047       : 4        |*                                       |
      2048 -> 4095       : 100      |****************************************|
      4096 -> 8191       : 64       |*************************               |
      8192 -> 16383      : 35       |**************                          |
     16384 -> 32767      : 2        |                                        |
     inet_csk_bind_conflict : count     distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 0        |                                        |
        32 -> 63         : 0        |                                        |
        64 -> 127        : 0        |                                        |
       128 -> 255        : 0        |                                        |
       256 -> 511        : 0        |                                        |
       512 -> 1023       : 0        |                                        |
      1024 -> 2047       : 1        |*                                       |
      2048 -> 4095       : 38       |****************************************|
      4096 -> 8191       : 9        |*********                               |
      8192 -> 16383      : 2        |**                                      |
     16384 -> 32767      : 1        |*                                       |
<restart happens>
     inet_csk_bind_conflict : count     distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 0        |                                        |
        32 -> 63         : 0        |                                        |
        64 -> 127        : 0        |                                        |
       128 -> 255        : 0        |                                        |
       256 -> 511        : 0        |                                        |
       512 -> 1023       : 0        |                                        |
      1024 -> 2047       : 9        |**                                      |
      2048 -> 4095       : 54       |****************                        |
      4096 -> 8191       : 15       |****                                    |
      8192 -> 16383      : 0        |                                        |
     16384 -> 32767      : 1        |                                        |
     32768 -> 65535      : 0        |                                        |
     65536 -> 131071     : 0        |                                        |
    131072 -> 262143     : 0        |                                        |
    262144 -> 524287     : 0        |                                        |
    524288 -> 1048575    : 0        |                                        |
   1048576 -> 2097151    : 0        |                                        |
   2097152 -> 4194303    : 130      |****************************************|
   4194304 -> 8388607    : 0        |                                        |
   8388608 -> 16777215   : 0        |                                        |
  16777216 -> 33554431   : 0        |                                        |
  33554432 -> 67108863   : 92       |****************************            |
     inet_csk_get_port   : count     distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 0        |                                        |
        32 -> 63         : 0        |                                        |
        64 -> 127        : 0        |                                        |
       128 -> 255        : 0        |                                        |
       256 -> 511        : 0        |                                        |
       512 -> 1023       : 0        |                                        |
      1024 -> 2047       : 11       |                                        |
      2048 -> 4095       : 132      |*********                               |
      4096 -> 8191       : 91       |******                                  |
      8192 -> 16383      : 13       |                                        |
     16384 -> 32767      : 0        |                                        |
     32768 -> 65535      : 0        |                                        |
     65536 -> 131071     : 0        |                                        |
    131072 -> 262143     : 0        |                                        |
    262144 -> 524287     : 0        |                                        |
    524288 -> 1048575    : 0        |                                        |
   1048576 -> 2097151    : 0        |                                        |
   2097152 -> 4194303    : 401      |****************************            |
   4194304 -> 8388607    : 274      |*******************                     |
   8388608 -> 16777215   : 0        |                                        |
  16777216 -> 33554431   : 16       |*                                       |
  33554432 -> 67108863   : 561      |****************************************|
     inet_csk_bind_conflict : count     distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 0        |                                        |
        32 -> 63         : 0        |                                        |
        64 -> 127        : 0        |                                        |
       128 -> 255        : 0        |                                        |
       256 -> 511        : 0        |                                        |
       512 -> 1023       : 0        |                                        |
      1024 -> 2047       : 6        |                                        |
      2048 -> 4095       : 68       |****                                    |
      4096 -> 8191       : 9        |                                        |
      8192 -> 16383      : 2        |                                        |
     16384 -> 32767      : 0        |                                        |
     32768 -> 65535      : 0        |                                        |
     65536 -> 131071     : 0        |                                        |
    131072 -> 262143     : 0        |                                        |
    262144 -> 524287     : 0        |                                        |
    524288 -> 1048575    : 0        |                                        |
   1048576 -> 2097151    : 0        |                                        |
   2097152 -> 4194303    : 650      |****************************************|
   4194304 -> 8388607    : 0        |                                        |
   8388608 -> 16777215   : 0        |                                        |
  16777216 -> 33554431   : 15       |                                        |
  33554432 -> 67108863   : 583      |***********************************     |
     inet_csk_get_port   : count     distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 0        |                                        |
        32 -> 63         : 0        |                                        |
        64 -> 127        : 0        |                                        |
       128 -> 255        : 0        |                                        |
       256 -> 511        : 0        |                                        |
       512 -> 1023       : 0        |                                        |
      1024 -> 2047       : 18       |*                                       |
      2048 -> 4095       : 263      |********************                    |
      4096 -> 8191       : 188      |**************                          |
      8192 -> 16383      : 186      |**************                          |
     16384 -> 32767      : 7        |                                        |
     32768 -> 65535      : 1        |                                        |
     65536 -> 131071     : 1        |                                        |
    131072 -> 262143     : 0        |                                        |
    262144 -> 524287     : 0        |                                        |
    524288 -> 1048575    : 0        |                                        |
   1048576 -> 2097151    : 0        |                                        |
   2097152 -> 4194303    : 37       |**                                      |
   4194304 -> 8388607    : 454      |**********************************      |
   8388608 -> 16777215   : 9        |                                        |
  16777216 -> 33554431   : 24       |*                                       |
  33554432 -> 67108863   : 526      |****************************************|
<soft lockup messages start happening>
     inet_csk_bind_conflict : count     distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 0        |                                        |
        32 -> 63         : 0        |                                        |
        64 -> 127        : 0        |                                        |
       128 -> 255        : 0        |                                        |
       256 -> 511        : 0        |                                        |
       512 -> 1023       : 0        |                                        |
      1024 -> 2047       : 20       |*                                       |
      2048 -> 4095       : 130      |**********                              |
      4096 -> 8191       : 40       |***                                     |
      8192 -> 16383      : 2        |                                        |
     16384 -> 32767      : 1        |                                        |
     32768 -> 65535      : 0        |                                        |
     65536 -> 131071     : 0        |                                        |
    131072 -> 262143     : 0        |                                        |
    262144 -> 524287     : 0        |                                        |
    524288 -> 1048575    : 0        |                                        |
   1048576 -> 2097151    : 0        |                                        |
   2097152 -> 4194303    : 506      |*************************************** |
   4194304 -> 8388607    : 0        |                                        |
   8388608 -> 16777215   : 0        |                                        |
  16777216 -> 33554431   : 23       |*                                       |
  33554432 -> 67108863   : 511      |****************************************|
               inet_csk_get_port             : count     distribution
                   0 -> 1                    : 0        |                    |
                   2 -> 3                    : 0        |                    |
                   4 -> 7                    : 0        |                    |
                   8 -> 15                   : 0        |                    |
                  16 -> 31                   : 0        |                    |
                  32 -> 63                   : 0        |                    |
                  64 -> 127                  : 0        |                    |
                 128 -> 255                  : 0        |                    |
                 256 -> 511                  : 0        |                    |
                 512 -> 1023                 : 0        |                    |
                1024 -> 2047                 : 9        |                    |
                2048 -> 4095                 : 356      |********************|
                4096 -> 8191                 : 230      |************        |
                8192 -> 16383                : 342      |******************* |
               16384 -> 32767                : 12       |                    |
               32768 -> 65535                : 1        |                    |
               65536 -> 131071               : 0        |                    |
              131072 -> 262143               : 0        |                    |
              262144 -> 524287               : 1        |                    |
              524288 -> 1048575              : 0        |                    |
             1048576 -> 2097151              : 0        |                    |
             2097152 -> 4194303              : 311      |*****************   |
             4194304 -> 8388607              : 163      |*********           |
             8388608 -> 16777215             : 1        |                    |
            16777216 -> 33554431             : 3        |                    |
            33554432 -> 67108863             : 338      |******************  |
            67108864 -> 134217727            : 55       |***                 |
           134217728 -> 268435455            : 65       |***                 |
           268435456 -> 536870911            : 36       |**                  |
           536870912 -> 1073741823           : 22       |*                   |
          1073741824 -> 2147483647           : 16       |                    |
          2147483648 -> 4294967295           : 7        |                    |
          4294967296 -> 8589934591           : 1        |                    |
     inet_csk_bind_conflict : count     distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 0        |                                        |
        32 -> 63         : 0        |                                        |
        64 -> 127        : 0        |                                        |
       128 -> 255        : 0        |                                        |
       256 -> 511        : 0        |                                        |
       512 -> 1023       : 0        |                                        |
      1024 -> 2047       : 2        |                                        |
      2048 -> 4095       : 86       |***                                     |
      4096 -> 8191       : 16       |                                        |
      8192 -> 16383      : 0        |                                        |
     16384 -> 32767      : 0        |                                        |
     32768 -> 65535      : 0        |                                        |
     65536 -> 131071     : 0        |                                        |
    131072 -> 262143     : 0        |                                        |
    262144 -> 524287     : 0        |                                        |
    524288 -> 1048575    : 0        |                                        |
   1048576 -> 2097151    : 187      |*******                                 |
   2097152 -> 4194303    : 975      |****************************************|
   4194304 -> 8388607    : 0        |                                        |
   8388608 -> 16777215   : 0        |                                        |
  16777216 -> 33554431   : 337      |*************                           |
  33554432 -> 67108863   : 442      |******************                      |
               inet_csk_get_port             : count     distribution
                   0 -> 1                    : 0        |                    |
                   2 -> 3                    : 0        |                    |
                   4 -> 7                    : 0        |                    |
                   8 -> 15                   : 0        |                    |
                  16 -> 31                   : 0        |                    |
                  32 -> 63                   : 0        |                    |
                  64 -> 127                  : 0        |                    |
                 128 -> 255                  : 0        |                    |
                 256 -> 511                  : 0        |                    |
                 512 -> 1023                 : 0        |                    |
                1024 -> 2047                 : 162      |****                |
                2048 -> 4095                 : 495      |**************      |
                4096 -> 8191                 : 66       |*                   |
                8192 -> 16383                : 6        |                    |
               16384 -> 32767                : 2        |                    |
               32768 -> 65535                : 0        |                    |
               65536 -> 131071               : 0        |                    |
              131072 -> 262143               : 0        |                    |
              262144 -> 524287               : 0        |                    |
              524288 -> 1048575              : 0        |                    |
             1048576 -> 2097151              : 0        |                    |
             2097152 -> 4194303              : 680      |********************|
             4194304 -> 8388607              : 166      |****                |
             8388608 -> 16777215             : 10       |                    |
            16777216 -> 33554431             : 6        |                    |
            33554432 -> 67108863             : 150      |****                |
            67108864 -> 134217727            : 275      |********            |
           134217728 -> 268435455            : 205      |******              |
           268435456 -> 536870911            : 151      |****                |
           536870912 -> 1073741823           : 137      |****                |
          1073741824 -> 2147483647           : 76       |**                  |
          2147483648 -> 4294967295           : 48       |*                   |
          4294967296 -> 8589934591           : 6        |                    |
          8589934592 -> 17179869183          : 2        |                    |
     inet_csk_bind_conflict : count     distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 0        |                                        |
        32 -> 63         : 0        |                                        |
        64 -> 127        : 0        |                                        |
       128 -> 255        : 0        |                                        |
       256 -> 511        : 0        |                                        |
       512 -> 1023       : 0        |                                        |
      1024 -> 2047       : 7        |                                        |
      2048 -> 4095       : 40       |***                                     |
      4096 -> 8191       : 0        |                                        |
      8192 -> 16383      : 0        |                                        |
     16384 -> 32767      : 0        |                                        |
     32768 -> 65535      : 0        |                                        |
     65536 -> 131071     : 0        |                                        |
    131072 -> 262143     : 0        |                                        |
    262144 -> 524287     : 0        |                                        |
    524288 -> 1048575    : 0        |                                        |
   1048576 -> 2097151    : 33       |**                                      |
   2097152 -> 4194303    : 159      |************                            |
   4194304 -> 8388607    : 0        |                                        |
   8388608 -> 16777215   : 0        |                                        |
  16777216 -> 33554431   : 311      |*************************               |
  33554432 -> 67108863   : 493      |****************************************|
               inet_csk_get_port             : count     distribution
                   0 -> 1                    : 0        |                    |
                   2 -> 3                    : 0        |                    |
                   4 -> 7                    : 0        |                    |
                   8 -> 15                   : 0        |                    |
                  16 -> 31                   : 0        |                    |
                  32 -> 63                   : 0        |                    |
                  64 -> 127                  : 0        |                    |
                 128 -> 255                  : 0        |                    |
                 256 -> 511                  : 0        |                    |
                 512 -> 1023                 : 0        |                    |
                1024 -> 2047                 : 129      |******************* |
                2048 -> 4095                 : 55       |********            |
                4096 -> 8191                 : 47       |*******             |
                8192 -> 16383                : 17       |**                  |
               16384 -> 32767                : 2        |                    |
               32768 -> 65535                : 0        |                    |
               65536 -> 131071               : 0        |                    |
              131072 -> 262143               : 0        |                    |
              262144 -> 524287               : 0        |                    |
              524288 -> 1048575              : 0        |                    |
             1048576 -> 2097151              : 30       |****                |
             2097152 -> 4194303              : 130      |********************|
             4194304 -> 8388607              : 24       |***                 |
             8388608 -> 16777215             : 0        |                    |
            16777216 -> 33554431             : 13       |**                  |
            33554432 -> 67108863             : 118      |******************  |
            67108864 -> 134217727            : 58       |********            |
           134217728 -> 268435455            : 17       |**                  |
           268435456 -> 536870911            : 7        |*                   |
           536870912 -> 1073741823           : 0        |                    |
          1073741824 -> 2147483647           : 1        |                    |
          2147483648 -> 4294967295           : 0        |                    |
          4294967296 -> 8589934591           : 1        |                    |
     inet_csk_bind_conflict : count     distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 0        |                                        |
        32 -> 63         : 0        |                                        |
        64 -> 127        : 0        |                                        |
       128 -> 255        : 0        |                                        |
       256 -> 511        : 0        |                                        |
       512 -> 1023       : 0        |                                        |
      1024 -> 2047       : 6        |*                                       |
      2048 -> 4095       : 14       |**                                      |
      4096 -> 8191       : 0        |                                        |
      8192 -> 16383      : 1        |                                        |
     16384 -> 32767      : 0        |                                        |
     32768 -> 65535      : 0        |                                        |
     65536 -> 131071     : 0        |                                        |
    131072 -> 262143     : 0        |                                        |
    262144 -> 524287     : 0        |                                        |
    524288 -> 1048575    : 0        |                                        |
   1048576 -> 2097151    : 158      |********************************        |
   2097152 -> 4194303    : 22       |****                                    |
   4194304 -> 8388607    : 0        |                                        |
   8388608 -> 16777215   : 0        |                                        |
  16777216 -> 33554431   : 192      |****************************************|
  33554432 -> 67108863   : 9        |*                                       |
<recovers>
     inet_csk_get_port   : count     distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 0        |                                        |
        32 -> 63         : 0        |                                        |
        64 -> 127        : 0        |                                        |
       128 -> 255        : 0        |                                        |
       256 -> 511        : 0        |                                        |
       512 -> 1023       : 0        |                                        |
      1024 -> 2047       : 10       |****************                        |
      2048 -> 4095       : 25       |****************************************|
      4096 -> 8191       : 16       |*************************               |
      8192 -> 16383      : 1        |*                                       |
     16384 -> 32767      : 0        |                                        |
     32768 -> 65535      : 1        |*                                       |
     inet_csk_bind_conflict : count     distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 0        |                                        |
        32 -> 63         : 0        |                                        |
        64 -> 127        : 0        |                                        |
       128 -> 255        : 0        |                                        |
       256 -> 511        : 0        |                                        |
       512 -> 1023       : 0        |                                        |
      1024 -> 2047       : 10       |*********************************       |
      2048 -> 4095       : 12       |****************************************|
     inet_csk_get_port   : count     distribution
         0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 0        |                                        |
        32 -> 63         : 0        |                                        |
        64 -> 127        : 0        |                                        |
       128 -> 255        : 0        |                                        |
       256 -> 511        : 0        |                                        |
       512 -> 1023       : 0        |                                        |
      1024 -> 2047       : 0        |                                        |
      2048 -> 4095       : 0        |                                        |
      4096 -> 8191       : 4        |****************************************|
      8192 -> 16383      : 1        |**********                              |

--=-PS77I0BnswqhqXDRakTH
Content-Type: text/x-patch
Content-Disposition: attachment; filename="tw-reuseport.patch"

commit ea66f43c5b4d94625ad7322e4097acd9a06d7fdd
Author: Josef Bacik <jbacik@fb.com>
Date:   Wed Dec 14 11:54:49 2016 -0800

    do reuseport too

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index c9b3eb7..567017b 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -55,6 +55,7 @@ struct inet_timewait_sock {
 #define tw_family		__tw_common.skc_family
 #define tw_state		__tw_common.skc_state
 #define tw_reuse		__tw_common.skc_reuse
+#define tw_reuseport		__tw_common.skc_reuseport
 #define tw_ipv6only		__tw_common.skc_ipv6only
 #define tw_bound_dev_if		__tw_common.skc_bound_dev_if
 #define tw_node			__tw_common.skc_nulls_node
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index a1b1057..04c560e 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -183,6 +183,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,
 		tw->tw_dport	    = inet->inet_dport;
 		tw->tw_family	    = sk->sk_family;
 		tw->tw_reuse	    = sk->sk_reuse;
+		tw->tw_reuseport    = sk->sk_reuseport;
 		tw->tw_hash	    = sk->sk_hash;
 		tw->tw_ipv6only	    = 0;
 		tw->tw_transparent  = inet->transparent;

--=-PS77I0BnswqhqXDRakTH--

--=-lkL1riTTK+BdyXvO4gxS--
