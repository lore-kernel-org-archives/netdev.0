From: Thomas Lendacky <tahm@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/1] NUMA aware scheduling per cpu vhost thread
Date: Fri, 23 Mar 2012 13:32:04 -0500
Message-ID: <1510318.F8gXLSD366@tomlt1.ibmoffice.com>
References: <1332460136.7730.19.camel@oc3660625478.ibm.com> <1332461790.7730.21.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:38009 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756566Ab2CWScU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2012 14:32:20 -0400
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tahm@linux.vnet.ibm.com>;
	Fri, 23 Mar 2012 14:32:19 -0400
In-Reply-To: <1332461790.7730.21.camel@oc3660625478.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I ran a series of TCP_RR, UDP_RR, TCP_STREAM and TCP_MAERTS tests
against the recent vhost patches. For simplicity, the patches
submitted by Anthony that increase the number of threads per vhost
instance I will call multi-worker and the patches submitted by Shirley
that provide a vhost thread per cpu I will call per-cpu.

Quick description of the tests:
  TCP_RR and UDP_RR using 256 byte request/response size in 1, 10, 30
  and 60 instances
  TCP_STREAM and TCP_MAERTS using 256, 1K, 4K and 16K message sizes
  and 1 and 4 instances

  Remote host to VM using 1, 4, 12 and 24 VMs (2 vCPUs) with the tests
  running between an external host and each VM.

  Local VM to VM using 2, 4, 12 and 24 VMs (2 vCPUs) with the tests
  running between VM pairs on the same host (no TCP_MAERTS done in
  this situation).

For TCP_RR and UDP_RR tests I report the transaction rate as the
score and the transaction rate / KVMhost CPU% as the efficiency.

For TCP_STREAM and TCP_MAERTS tests I report the throughput in Mbps
as the score and the throughput / KVMhost CPU% as the efficiency.

The KVM host machine is a nehalem-based 2-socket, 4-cores/socket
system (E5530 @ 2.40GHz) with hyperthreading disabled and an Intel
10GbE single port network adapter.

There's a lot of data and I hope this is the clearest way to report
it.  The remote host to VM results are first followed by the local
VM to VM results.


Remote Host to VM:
 Host to 1 VM
                -   Base    -  -Multi-Worker- -  Per-CPU  -
  Test     Inst   Score   Eff    Score   Eff    Score   Eff
  TCP_RR      1   9,587   984    9,725 1,145    9,252 1,041 
             10  63,919 3,095   51,841 2,415   55,226 2,884 
             30  85,646 3,288  127,277 3,242  145,644 4,092 
             60 117,448 3,929  148,330 3,616  137,996 3,898 

  UDP_RR      1  10,815 1,174   10,125 1,255    7,913 1,150 
             10  53,989 3,082   59,590 2,875   52,353 3,328 
             30  91,484 4,115   95,312 3,042  110,715 3,659 
             60 107,466 4,689  173,443 4,351  158,141 4,235 

  TCP_STREAM
         256  1   2,724   140    2,450   131    2,681   150 
              4   5,027   137    4,147   146    3,998   117 

        1024  1   5,602   235    4,623   169    5,425   238 
              4   5,987   212    5,991   133    6,827   175 

        4096  1   6,202   256    6,753   211    7,247   279 
              4   4,996   192    5,771   159    7,124   202 

       16384  1   6,258   259    7,211   214    8,453   308 
              4   4,591   179    5,788   181    6,925   217 

  TCP_MAERTS
         256  1   1,951    85    1,871    89    1,899    97 
              4   4,757   129    4,102   140    4,279   116 

        1024  1   7,479   381    6,970   371    7,374   427 
              4   8,931   385    6,612   258    8,731   417 

        4096  1   9,276   464    9,296   456    9,131   510 
              4   9,381   452    9,032   367    9,338   446 

       16384  1   9,153   496    8,817   589    9,238   516 
              4   9,358   478    9,006   367    9,350   462 

 Host to 1 VM (VM pinned to a socket)
                -   Base    -  -Multi-Worker- -  Per-CPU  -
  Test     Inst   Score   Eff    Score   Eff    Score   Eff
  TCP_RR      1   9,992 1,019    9,899   917    8,963   899 
             10  60,731 3,236   60,015 2,444   55,860 3,059 
             30 127,375 4,042  146,571 3,922  163,806 4,389 
             60 173,021 4,972  149,549 4,662  161,397 4,330 

  UDP_RR      1  10,854 1,253    7,983 1,120    7,647 1,206 
             10  68,128 3,804   64,335 4,067   53,343 3,233 
             30  92,456 3,994  112,101 4,219  111,610 3,598 
             60 135,741 4,590  184,441 4,422  184,527 4,546 

  TCP_STREAM
         256  1   2,564   146    2,530   147    2,497   150 
              4   4,757   139    4,300   127    4,245   124 

        1024  1   4,700   209    6,062   323    5,627   247 
              4   6,828   214    7,125   153    6,561   172 

        4096  1   6,676   281    7,672   286    7,760   290 
              4   6,258   236    6,410   171    7,354   225 

       16384  1   6,712   289    8,217   297    8,457   322 
              4   5,764   235    6,285   200    7,554   245 

  TCP_MAERTS
         256  1   1,673    82    1,444    71    1,756    88 
              4   6,385   175    5,671   155    5,685   153 

        1024  1   7,500   427    6,884   414    7,640   429 
              4   9,310   444    8,659   496    8,200   350 

        4096  1   8,427   477    9,201   515    8,825   422 
              4   9,372   478    9,184   394    9,391   446 

       16384  1   8,840   500    9,205   555    9,239   482 
              4   9,379   495    9,079   385    9,389   472 

 Host to 4 VMs
                -   Base    -  -Multi-Worker- -  Per-CPU  -
  Test     Inst   Score   Eff    Score   Eff    Score   Eff
  TCP_RR      1  38,635   949   34,063   843   35,432   897 
             10 193,703 2,604  157,699 1,841  180,323 2,858 
             30 279,736 3,301  170,343 1,739  269,827 2,875 
             60 308,838 3,555  170,486 1,738  285,073 2,988 

  UDP_RR      1  42,209 1,136   36,035   904   36,974   975 
             10 177,286 2,616  166,999 2,043  178,470 2,466 
             30 296,415 3,731  221,738 2,488  260,630 2,966 
             60 353,784 4,179  209,489 2,152  306,792 3,440 

  TCP_STREAM
         256  1   8,409   113    7,517   101    7,178   115 
              4   8,963    93    7,825    80    8,606    91 

        1024  1   9,382   119   10,223   192    9,314   128 
              4   9,233   101    9,085   110    8,585   105 

        4096  1   9,391   124    9,393   125    9,300   140 
              4   9,303   103    9,151   102    8,601   106 

       16384  1   9,395   121    8,715   128    9,378   135 
              4   9,322   105    9,135   101    8,691   121 

  TCP_MAERTS
         256  1   8,629   125    7,045   112    7,559   109 
              4   9,389   145    7,091    80    9,335   156 

        1024  1   9,385   201    9,349   148    9,320   248 
              4   9,392   154    9,340   148    9,390   226 

        4096  1   9,387   239    9,339   151    9,379   291 
              4   9,392   167    9,389   124    9,390   259 

       16384  1   9,374   236    9,366   150    9,391   317 
              4   9,365   167    9,394   123    9,390   284 

 Host to 12 VMs
                -   Base    -  -Multi-Worker- -  Per-CPU  -
  Test     Inst   Score   Eff    Score   Eff    Score   Eff
  TCP_RR      1  79,628   928   85,717   944   72,760   885
             10 106,348 1,067   94,032   944  164,548 2,017
             30 131,313 1,318  116,431 1,168  206,560 2,367
             60 156,868 1,574  152,205 1,527  223,701 2,250

  UDP_RR      1  90,762 1,059   93,904 1,037   75,512   919
             10 149,381 1,499  113,254 1,136  194,153 1,951
             30 177,803 1,783  132,818 1,333  235,682 2,370
             60 201,833 2,025  154,871 1,554  258,133 2,595

  TCP_STREAM
         256  1   8,549    86    7,173    72    8,407    85
              4   8,910    89    8,693    87    8,768    88

        1024  1   9,397    95    9,371    94    9,376    95
              4   9,289    93    9,268   100    8,898    92

        4096  1   9,399    95    9,415    95    9,401    97
              4   9,336    94    9,319    94    8,938    94

       16384  1   9,405    95    9,402    96    9,397   102
              4   9,366    94    9,345    94    8,890    94

  TCP_MAERTS
         256  1   4,646    49    2,273    23    9,232   135
              4   9,393   107    8,019    81    9,414   134

        1024  1   9,393   115    9,403   104    9,399   178
              4   9,406   110    9,383    98    9,392   157

        4096  1   9,393   114    9,409   104    9,388   202
              4   9,388   110    9,387    98    9,382   181

       16384  1   9,396   114    9,391   104    9,394   221
              4   9,411   110    9,384    98    9,391   192

 Host to 24 VMs
                -   Base    -  -Multi-Worker- -  Per-CPU  -
  Test     Inst   Score   Eff    Score   Eff    Score   Eff
  TCP_RR      1 110,139 1,118  101,765 1,033   79,189   805
             10  94,757   948   90,872   915  156,821 1,581
             30 119,904 1,199  120,728 1,207  214,151 2,211
             60 144,684 1,457  146,788 1,468  240,963 2,513

  UDP_RR      1 129,655 1,316  120,071 1,201   91,208   914
             10 119,204 1,201  104,645 1,046  208,432 2,340
             30 158,887 1,601  136,629 1,366  249,329 2,517
             60 179,365 1,794  159,883 1,610  259,018 2,651

  TCP_STREAM
         256  1   5,899    59    4,258    44    8,071    82
              4   8,739    89    8,195    83    7,934    82

        1024  1   8,477    86    7,498    76    9,268    93
              4   9,205    93    9,171    94    8,159    84

        4096  1   9,334    96    8,992    92    9,324    97
              4   9,255    95    9,221    92    8,237    85

       16384  1   9,373    96    9,356    95    9,311    96
              4   9,283    94    9,275    93    8,317    86

  TCP_MAERTS
         256  1     739     7      770     8    9,186   129
              4   7,804    79    7,573    76    9,253   122

        1024  1   1,763    18    1,759    18    9,287   146
              4   9,204    99    9,166    93    9,389   155

        4096  1   3,430    35    3,403    35    9,348   161
              4   9,372   100    9,315    95    9,385   151

       16384  1   9,309   102    9,306    97    9,353   175
              4   9,378   100    9,392    96    9,377   159



Local VM to VM:

 1 VM to 1 VM
                -   Base    -  -Multi-Worker- -  Per-CPU  -
  Test     Inst   Score   Eff    Score   Eff    Score   Eff
  TCP_RR      1   7,422   506    7,698   462    6,281   450 
             10  49,662 1,362   47,553 1,205   43,258 1,270 
             30  91,657 1,538   99,319 1,471   89,478 1,499 
             60 106,168 1,658  106,430 1,503   99,205 1,576 

  UDP_RR      1   8,414   552    8,532   528    6,976   499 
             10  58,359 1,645   55,283 1,398   48,094 1,457 
             30  91,046 1,736  109,403 1,721   92,109 1,715 
             60 128,835 2,021  130,382 1,807  118,563 1,853 

  TCP_STREAM
         256  1   2,029    60    1,923    54    1,998    64 
              4   3,861    66    3,445    53    2,914    54 

        1024  1   7,374   205    6,465   174    5,704   165 
              4   8,474   196    7,541   161    6,274   156 

        4096  1  12,825   295   11,921   275   10,262   262 
              4  12,639   253   13,395   260   11,451   264 

       16384  1  14,576   331   14,141   291   11,925   305 
              4  16,016   327   14,210   274   13,656   308 


 1 VM to 1 VM (each VM pinned to a socket)
                -   Base    -  -Multi-Worker- -  Per-CPU  -
  Test     Inst   Score   Eff    Score   Eff    Score   Eff
  TCP_RR      1   7,145   489    7,840   477    5,965   467 
             10  51,016 1,406   47,881 1,223   45,232 1,288 
             30  92,785 1,580  103,453 1,512   91,437 1,523 
             60 120,160 1,817  115,058 1,595  102,734 1,611 

  UDP_RR      1   7,908   547    8,704   541    6,552   528 
             10  59,807 1,653   56,598 1,435   50,524 1,488 
             30  90,302 1,738  113,861 1,765   94,640 1,720 
             60 141,684 2,196  141,866 1,919  125,334 1,917 

  TCP_STREAM
         256  1   2,210    64    1,291    32    2,069    64 
              4   3,993    64    3,441    52    2,780    50 

        1024  1   8,106   217    7,571   198    5,709   165 
              4   8,471   206    8,756   174    6,531   157 

        4096  1  15,360   350   13,825   303   10,717   271 
              4  14,671   330   12,604   263   11,266   258 

       16384  1  18,284   395   16,305   337   13,185   317 
              4  15,451   331   12,438   247   14,699   316 


 2 VMs to 2 VMs (4 VMs total)
                -   Base    -  -Multi-Worker- -  Per-CPU  -
  Test     Inst   Score   Eff    Score   Eff    Score   Eff
  TCP_RR      1  15,498   491   16,518   460   13,008   441 
             10  71,425   983   79,711 1,063   85,087 1,037 
             30 102,132 1,436   82,191 1,145  100,504 1,076 
             60 127,670 1,608   96,815 1,262  104,694 1,119 

  UDP_RR      1  17,091   548   18,214   538   14,780   492 
             10  77,682 1,129   87,523 1,235   86,755 1,165 
             30 131,830 1,826   92,844 1,327  111,839 1,232 
             60 145,688 1,952  111,315 1,520  116,358 1,296 

  TCP_STREAM
         256  1   5,085    72    3,900    50    2,430    38 
              4   6,622    70    4,337    48    5,032    58 

        1024  1  15,262   206   15,022   195    7,000   115 
              4  14,205   174   15,288   174   11,030   148 

        4096  1  15,020   197   21,694   261   13,583   198 
              4  16,818   205   16,076   195   17,175   238 

       16384  1  19,671   261   23,699   290   22,396   306 
              4  18,648   229   17,901   218   17,122   251 

 6 VMs to 6 VMs (12 VMs total)
                -   Base    -  -Multi-Worker- -  Per-CPU  -
  Test     Inst   Score   Eff    Score   Eff    Score   Eff
  TCP_RR      1  30,242   400   32,281   390   27,737   401 
             10  73,461   783   61,856   644   93,259 1,000 
             30  98,638 1,034   81,799   844  107,022 1,121 
             60 114,238 1,200   91,772   944  110,839 1,152 

  UDP_RR      1  33,017   438   35,540   429   30,022   438 
             10  84,676   910   67,838   711  112,339 1,220 
             30 110,799 1,156   90,555   932  128,928 1,357 
             60 129,679 1,354  100,715 1,033  136,503 1,429 

  TCP_STREAM
         256  1   6,947    72    5,380    56    6,138    72 
              4   8,400    85    7,660    77    8,893    89 

        1024  1  13,698   146   10,307   108   13,023   158 
              4  15,391   157   13,242   135   17,264   182 

        4096  1  18,928   202   14,580   154   16,970   189 
              4  18,826   191   17,262   175   19,558   212 

       16384  1  22,176   234   17,716   187   21,245   243 
              4  21,306   215   20,332   206   18,353   227 

 12 VMs to 12 VMs (24 VMs total)
                -   Base    -  -Multi-Worker- -  Per-CPU  -
  Test     Inst   Score   Eff    Score   Eff    Score   Eff
  TCP_RR      1  72,926   731   67,338   675   32,662   387 
             10  62,441   625   59,277   594   87,286   891 
             30  72,761   728   67,760   679  102,549 1,041 
             60  78,087   782   74,654   748  100,687 1,016 

  UDP_RR      1  82,662   829   80,875   810   34,915   421 
             10  71,424   716   67,754   679  111,753 1,147 
             30  79,495   796   75,512   756  134,576 1,372 
             60  83,339   835   77,523   778  137,058 1,390 

  TCP_STREAM
         256  1   2,870    29    2,631    26    7,907    80 
              4   8,424    84    8,026    80    8,929    90 

        1024  1   3,674    37    3,121    31   15,644   164 
              4  14,256   143   13,342   134   16,116   168 

        4096  1   5,068    51    4,366    44   16,179   168 
              4  17,015   171   16,321   164   17,940   186 

       16384  1   9,768    98    9,025    90   19,233   203 
              4  18,981   190   18,202   183   18,964   203 


On Thursday, March 22, 2012 05:16:30 PM Shirley Ma wrote:
> Resubmit it with the right format.
> 
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> Tested-by: Tom Lendacky <toml@us.ibm.com>
> ---
> 
>  drivers/vhost/net.c                  |   26 ++-
>  drivers/vhost/vhost.c                |  300
> ++++++++++++++++++++++++---------- drivers/vhost/vhost.h                |  
> 16 ++-
>  3 files changed, 243 insertions(+), 103 deletions(-)
> 
