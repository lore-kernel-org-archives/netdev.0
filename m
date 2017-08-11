From: isdn@linux-pingi.de
Subject: Re: [PATCH] mISDN: Fix null pointer dereference at mISDN_FsmNew
Date: Fri, 11 Aug 2017 16:31:41 +0200
Message-ID: <09d00804-bcd4-e6b8-df7d-7b74e578e557@linux-pingi.de>
References: <1502456242-1695-1-git-send-email-vasilyev@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: Geliang Tang <geliangtang@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org
To: Anton Vasilyev <vasilyev@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502456242-1695-1-git-send-email-vasilyev@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Anton,

good spot, thanks. Dave please apply.

Karsten

Am 11.08.2017 um 14:57 schrieb Anton Vasilyev:
> If mISDN_FsmNew() fails to allocate memory for jumpmatrix
> then null pointer dereference will occur on any write to
> jumpmatrix.
> 
> The patch adds check on successful allocation and
> corresponding error handling.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Anton Vasilyev <vasilyev@ispras.ru>
> ---
>  drivers/isdn/mISDN/fsm.c    |  5 ++++-
>  drivers/isdn/mISDN/fsm.h    |  2 +-
>  drivers/isdn/mISDN/layer1.c |  3 +--
>  drivers/isdn/mISDN/layer2.c | 15 +++++++++++++--
>  drivers/isdn/mISDN/tei.c    | 20 +++++++++++++++++---
>  5 files changed, 36 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/isdn/mISDN/fsm.c b/drivers/isdn/mISDN/fsm.c
> index 78fc5d5..92e6570 100644
> --- a/drivers/isdn/mISDN/fsm.c
> +++ b/drivers/isdn/mISDN/fsm.c
> @@ -26,7 +26,7 @@
>  
>  #define FSM_TIMER_DEBUG 0
>  
> -void
> +int
>  mISDN_FsmNew(struct Fsm *fsm,
>  	     struct FsmNode *fnlist, int fncount)
>  {
> @@ -34,6 +34,8 @@ mISDN_FsmNew(struct Fsm *fsm,
>  
>  	fsm->jumpmatrix = kzalloc(sizeof(FSMFNPTR) * fsm->state_count *
>  				  fsm->event_count, GFP_KERNEL);
> +	if (fsm->jumpmatrix == NULL)
> +		return -ENOMEM;
>  
>  	for (i = 0; i < fncount; i++)
>  		if ((fnlist[i].state >= fsm->state_count) ||
> @@ -45,6 +47,7 @@ mISDN_FsmNew(struct Fsm *fsm,
>  		} else
>  			fsm->jumpmatrix[fsm->state_count * fnlist[i].event +
>  					fnlist[i].state] = (FSMFNPTR) fnlist[i].routine;
> +	return 0;
>  }
>  EXPORT_SYMBOL(mISDN_FsmNew);
>  
> diff --git a/drivers/isdn/mISDN/fsm.h b/drivers/isdn/mISDN/fsm.h
> index 928f5be..e1def84 100644
> --- a/drivers/isdn/mISDN/fsm.h
> +++ b/drivers/isdn/mISDN/fsm.h
> @@ -55,7 +55,7 @@ struct FsmTimer {
>  	void *arg;
>  };
>  
> -extern void -(struct Fsm *, struct FsmNode *, int);
> +extern int mISDN_FsmNew(struct Fsm *, struct FsmNode *, int);
>  extern void mISDN_FsmFree(struct Fsm *);
>  extern int mISDN_

(struct FsmInst *, int , void *);
>  extern void mISDN_FsmChangeState(struct FsmInst *, int);
> diff --git a/drivers/isdn/mISDN/layer1.c b/drivers/isdn/mISDN/layer1.c
> index bebc57b..3192b0e 100644
> --- a/drivers/isdn/mISDN/layer1.c
> +++ b/drivers/isdn/mISDN/layer1.c
> @@ -414,8 +414,7 @@ l1_init(u_int *deb)
>  	l1fsm_s.event_count = L1_EVENT_COUNT;
>  	l1fsm_s.strEvent = strL1Event;
>  	l1fsm_s.strState = strL1SState;
> -	mISDN_FsmNew(&l1fsm_s, L1SFnList, ARRAY_SIZE(L1SFnList));
> -	return 0;
> +	return mISDN_FsmNew(&l1fsm_s, L1SFnList, ARRAY_SIZE(L1SFnList));
>  }
>  
>  void
> diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
> index 7243a67..9ff0903 100644
> --- a/drivers/isdn/mISDN/layer2.c
> +++ b/drivers/isdn/mISDN/layer2.c
> @@ -2247,15 +2247,26 @@ static struct Bprotocol X75SLP = {
>  int
>  Isdnl2_Init(u_int *deb)
>  {
> +	int res;
>  	debug = deb;
>  	mISDN_register_Bprotocol(&X75SLP);
>  	l2fsm.state_count = L2_STATE_COUNT;
>  	l2fsm.event_count = L2_EVENT_COUNT;
>  	l2fsm.strEvent = strL2Event;
>  	l2fsm.strState = strL2State;
> -	mISDN_FsmNew(&l2fsm, L2FnList, ARRAY_SIZE(L2FnList));
> -	TEIInit(deb);
> +	res = mISDN_FsmNew(&l2fsm, L2FnList, ARRAY_SIZE(L2FnList));
> +	if (res)
> +		goto error;
> +	res = TEIInit(deb);
> +	if (res)
> +		goto error_fsm;
>  	return 0;
> +
> +error_fsm:
> +	mISDN_FsmFree(&l2fsm);
> +error:
> +	mISDN_unregister_Bprotocol(&X75SLP);
> +	return res;
>  }
>  
>  void
> diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
> index 908127e..12d9e5f 100644
> --- a/drivers/isdn/mISDN/tei.c
> +++ b/drivers/isdn/mISDN/tei.c
> @@ -1387,23 +1387,37 @@ create_teimanager(struct mISDNdevice *dev)
>  
>  int TEIInit(u_int *deb)
>  {
> +	int res;
>  	debug = deb;
>  	teifsmu.state_count = TEI_STATE_COUNT;
>  	teifsmu.event_count = TEI_EVENT_COUNT;
>  	teifsmu.strEvent = strTeiEvent;
>  	teifsmu.strState = strTeiState;
> -	mISDN_FsmNew(&teifsmu, TeiFnListUser, ARRAY_SIZE(TeiFnListUser));
> +	res = mISDN_FsmNew(&teifsmu, TeiFnListUser, ARRAY_SIZE(TeiFnListUser));
> +	if (res)
> +		goto error;
>  	teifsmn.state_count = TEI_STATE_COUNT;
>  	teifsmn.event_count = TEI_EVENT_COUNT;
>  	teifsmn.strEvent = strTeiEvent;
>  	teifsmn.strState = strTeiState;
> -	mISDN_FsmNew(&teifsmn, TeiFnListNet, ARRAY_SIZE(TeiFnListNet));
> +	res = mISDN_FsmNew(&teifsmn, TeiFnListNet, ARRAY_SIZE(TeiFnListNet));
> +	if (res)
> +		goto error_smn;
>  	deactfsm.state_count =  DEACT_STATE_COUNT;
>  	deactfsm.event_count = DEACT_EVENT_COUNT;
>  	deactfsm.strEvent = strDeactEvent;
>  	deactfsm.strState = strDeactState;
> -	mISDN_FsmNew(&deactfsm, DeactFnList, ARRAY_SIZE(DeactFnList));
> +	res = mISDN_FsmNew(&deactfsm, DeactFnList, ARRAY_SIZE(DeactFnList));
> +	if (res)
> +		goto error_deact;
>  	return 0;
> +
> +error_deact:
> +	mISDN_FsmFree(&teifsmn);
> +error_smn:
> +	mISDN_FsmFree(&teifsmu);
> +error:
> +	return res;
>  }
>  
>  void TEIFree(void)
> 
