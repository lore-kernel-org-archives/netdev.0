From: "Jim Schutt" <jaschut@sandia.gov>
Subject: Re: [RFC PATCH 0/6] Understanding delays due to throttling
 under very heavy write load
Date: Mon, 13 Feb 2012 08:26:03 -0700
Message-ID: <4F392B8B.4030204@sandia.gov>
References: <1328111668-10068-1-git-send-email-jaschut@sandia.gov>
 <CAF3hT9CFkxnWR4zoTRPtyGU5CbfV_PvL+=dqnvZcr7G0HBOb+w@mail.gmail.com>
 <4F2AF085.6000405@sandia.gov>
 <CAF3hT9AcxxNtscFczP8fShSsaBm_4zhLQZ2F5c7h1YswVaXHkA@mail.gmail.com>
 <4F2C08A7.2050507@sandia.gov> <3032884323297001561@unknownmsgid>
 <4F2C6EE6.4050008@sandia.gov>
 <CAC-hyiHSNv_VgLcyVCrJ66HxTGFNBONrmmBddJk5326dLTKgkw@mail.gmail.com>
 <4F2FFDD3.1010100@sandia.gov>
 <CAC-hyiEdAd++dQFBjPDutqipQcMXZqh4RdEEyA=v12vs6ueDxA@mail.gmail.com>
 <4F3019E9.80607@sandia.gov>
 <CAF3hT9CW7_CF4iT0cY858kgkke7Wu=TK7ULzPhFj-AW9jycyZA@mail.gmail.com>
 <4F343239.2010907@sandia.gov>
 <CAGnVnB=beb2XMB55FfG7TgBeqa4gmb=O1S54=s+V6rANeoq3ug@mail.gmail.com>
 <4F3453A7.9000408@sandia.gov>
 <CAGnVnBm1hyXfk4Wnb57j3EYTwUwjSDYtHg_zPQ86B8vorgJ4Cw@mail.gmail.com>
 <4F35388B.4070601@sandia.gov>
 <CAGnVnBmv5HovMJjejKemJwjFrGOb77dnTqLpQzHtPFU4_nrvkg@mail.gmail.com>
 <4F35A3B5.7090909@sandia.gov>
 <CAGnVnB=scn13bE-+0xn4cqYnStObN+VvSMv4bL3whvRzXv1dFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: ceph-devel@vger.kernel.org, netdev@vger.kernel.org
To: "sridhar basam" <sri@basam.org>
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <CAGnVnB=scn13bE-+0xn4cqYnStObN+VvSMv4bL3whvRzXv1dFw@mail.gmail.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/10/2012 05:05 PM, sridhar basam wrote:
>> >  But the server never ACKed that packet.  Too busy?
>> >
>> >  I was collecting vmstat data during the run; here's the important bits:
>> >
>> >  Fri Feb 10 11:56:51 MST 2012
>> >  vmstat -w 8 16
>> >  procs -------------------memory------------------ ---swap-- -----io----
>> >  --system-- -----cpu-------
>> >    r  b       swpd       free       buff      cache   si   so    bi    bo   in
>> >     cs  us sy  id wa st
>> >  13 10          0     250272        944   37859080    0    0     7  5346 1098
>> >    444   2  5  92  1  0
>> >  88  8          0     260472        944   36728776    0    0     0 1329838
>> >  257602 68861  19 73   5  4  0
>> >  100 10          0     241952        944   36066536 0 0     0 1635891 340724
>> >  85570  22 68   6  4  0
>> >  105  9          0     250288        944   34750820 0 0     0 1584816 433223
>> >  111462  21 73   4  3  0
>> >  126  3          0     259908        944   33841696    0    0     0 749648
>> >  225707 86716   9 83   4  3  0
>> >  157  2          0     245032        944   31572536 0 0     0 736841 252406
>> >  99083   9 81   5  5  0
>> >  45 17          0     246720        944   28877640    0    0     1 755085
>> >  282177 116551   8 77   9  5  0
> Holy crap! That might explain why you aren't seeing anything. You are
> writing out over a 1.6 million blocks/sec. That too averaged over a 8
> second interval. I bet the missed acks are when this is happening.
> What sort of I/O load is going through this system during those times?
> What sort of filesystem and Linux system are these OSDs on?

Dual socket Nehalem EP @ 3 GHz, 24 ea. 7200RPM SAS drives w/ 64 MB cache,
3 LSI SAS HBAs w/8 drives per HBA, btrfs, 3.2.0 kernel.  Each OSD
has a ceph journal and a ceph data store on a single drive.

I'm running 24 OSDs on such a box; all that write load is the result
of dd from 166 linux ceph clients.

FWIW, I've seen these boxes sustain > 2 GB/s for 60 sec or so under
this load, when I have TSO/GSO/GRO turned on, and am writing to
a freshly created ceph filesystem.

That lasts until my OSDs get stalled reading from a socket, as
documented by those packet traces I posted.

If you compare the timestamps on the retransmits to the times
that vmstat is dumping reports, at least some of the retransmits
hit the system when it is ~80% idle.

-- Jim

>
>   Sridhar
>
>
>


